//
//  ListContactViewModel.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactViewModel.h"
#import "ContactViewEntity.h"
#import <Contacts/Contacts.h>
#import "NSArrayExtension.h"
#import <UIKit/UIKit.h>
#import "Logging.h"

@interface ContactViewModel() {
    BOOL _contactIsLoaded;
}

- (void) setupEvents;
- (ContactViewEntity *) parseContactEntity: (ContactBusEntity *) entity;
@end

@implementation ContactViewModel

@synthesize listContacts = _listContacts;

@synthesize listSelectedContacts = _listSelectedContacts;

@synthesize contactBus = _contactBus;

@synthesize searchObservable;

@synthesize contactBookObservable;

@synthesize numberOfSelectedContactObservable;

@synthesize numberOfContactObservable;

@synthesize indexCellNeedUpdateObservable;

- (id)initWithBus:(id<ContactBusProtocol>)bus {
    self->_contactBus = bus;
    self->_contactIsLoaded = NO;
    
//    List source initialization
    self.listContacts = [[NSMutableArray alloc] init];
    self.listSelectedContacts = [[NSMutableArray alloc] init];
    
//    Data binding initialization
    self.searchObservable = [[DataBinding<NSString *> alloc] initWithValue:@""];
    self.contactBookObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    self.numberOfSelectedContactObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    self.numberOfContactObservable = [[DataBinding<NSNumber *> alloc] initWithValue:[NSNumber numberWithInt:0]];
    self.indexCellNeedUpdateObservable = [[DataBinding<NSNumber *> alloc] initWithValue:nil];
    
    [self setupEvents];
    
    return self;
}

- (void)setupEvents {
    __weak ContactViewModel * weakSelf = self;
    
//    Listen Contact store changed
    self->_contactBus.contactChangedObservable = ^(NSArray * contactsUpdated) {
        //            Update avatar for current contacts
        [weakSelf.listContacts enumerateObjectsUsingBlock:^(ContactViewEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weakSelf.contactBus getImageFromId:obj.identifier completion:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage * image = [UIImage imageWithData:imageData];
                    obj.avatar = image;
                    if (obj.waitImageToExcuteQueue) {
                        obj.waitImageToExcuteQueue(image, obj.identifier);
                    }
                } else {
                    [Logging error: error.localizedDescription];
                }
            }];
        }];
        
        [contactsUpdated enumerateObjectsUsingBlock:^(ContactBusEntity*  _Nonnull updatedEntity, NSUInteger idx, BOOL * _Nonnull stop) {
            for (int i = 0; i < weakSelf.listContacts.count ; i++ ) {
                ContactViewEntity * oldEntity = weakSelf.listContacts[i];
                if ([oldEntity.identifier isEqualToString:updatedEntity.identifier] && ![oldEntity isEqualWithBusEntity:updatedEntity]) {
                    [weakSelf.listContacts[i] updateContactWith:updatedEntity];
                }
            }
        }];
        
        weakSelf.contactBookObservable.value = [NSNumber numberWithInt:[weakSelf.contactBookObservable.value intValue] + 1];
    };
}

- (ContactViewEntity *)parseContactEntity:(ContactBusEntity *)entity {
    NSString * fullName = [NSString stringWithFormat:@"%@ %@", entity.givenName, entity.familyName];
    ContactViewEntity *viewEntity =  [[ContactViewEntity alloc] initWithIdentifier:entity.identifier name:fullName description:@"temp"];
    
    [self->_contactBus getImageFromId:entity.identifier completion:^(NSData * imageData, NSError * error) {
        if (!error) {
            UIImage * image = [UIImage imageWithData:imageData];
            viewEntity.avatar = image;
            if (viewEntity.waitImageToExcuteQueue) {
                viewEntity.waitImageToExcuteQueue(image, entity.identifier);
            }
        } else {
            [Logging error: error.localizedDescription];
        }
    }];
    return viewEntity;
}

- (void)addContacts:(NSArray *)batchOfContact {
    for (int i = 0; i < self.listSelectedContacts.count; i++) {
        ContactViewEntity * selectedContact = self.listSelectedContacts[i];
        
        for (int j = 0; j < batchOfContact.count; j++) {
            ContactViewEntity * newContact = batchOfContact[j];
            
            if ([selectedContact.identifier isEqualToString:newContact.identifier]) {
                newContact.isChecked = selectedContact.isChecked;
            }
        }
    }
    [self.listContacts addObjectsFromArray:batchOfContact];
    self.numberOfContactObservable.value = [NSNumber numberWithUnsignedInteger:self.listContacts.count];
}

#pragma mark Public function
- (void)requestPermission:(void (^)(BOOL, NSError *))completion {
    [self->_contactBus requestPermission:completion];
}

- (void)loadContacts:(void (^)(BOOL isSuccess, NSError * error, int numberOfContacts))completion {
    [self->_contactBus loadContacts:^(NSError * error, BOOL isDone) {
        if (error) {
            completion(NO, error, 0);
            [Logging error:[NSString stringWithFormat:@"Load contact failt, error: %@", error.localizedDescription]];
        } else {
            if (!self->_contactIsLoaded) {
                [self loadBatchOfDetailedContacts:completion];
                self->_contactIsLoaded = YES;
            }
        }
    }];
}

- (void)loadBatchOfDetailedContacts:(void (^)(BOOL isSuccess, NSError * error, int numberOfContacts))completion {
    [self->_contactBus loadBatchOfDetailedContacts:^(NSArray<ContactBusEntity *> * listContactBusEntity, NSError * error) {
        if (error) {
            if (completion)
                completion(NO, error, 0);
            [Logging error:[NSString stringWithFormat:@"Load batch contact failt, error: %@", error.localizedDescription]];
        } else {
            NSArray * batchOfContact = [listContactBusEntity map:^ContactViewEntity* _Nonnull(ContactBusEntity*  _Nonnull obj) {
                return [self parseContactEntity:obj];
            }];
            
            [self addContacts:batchOfContact];
            
            if (completion)
                completion(YES, nil, (int)batchOfContact.count);
        }
    }];
}

- (int)getNumberOfContacts {
    return (int)self.listContacts.count;
}

- (ContactViewEntity *)getContactAt:(int)index {
    if (index < self.listContacts.count) {
        return self.listContacts[index];
    }
    return nil;
}

- (void)searchContactWithKeyName:(NSString *)key completion:(void (^)(void))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.listContacts = [[NSMutableArray alloc] init];
        handler();
        [self->_contactBus searchContactByName:key completion:^(void) {
            [self loadBatchOfDetailedContacts:^(BOOL isSuccess, NSError *error, int numberOfContacts) {
                if (!error) {
                    handler();
                }
            }];
        }];
    });
}

- (void)selectectContactAtIndex:(int)index {
    ContactViewEntity * contact = self.listContacts[index];
    contact.isChecked = !contact.isChecked;
    
    if (contact.isChecked) {
        [self.listSelectedContacts addObject:contact];
    } else if ([self.listSelectedContacts containsObject:contact]) {
        [self.listSelectedContacts removeObject:contact];
    }
    self.numberOfSelectedContactObservable.value = [NSNumber numberWithInt:(int)self.listSelectedContacts.count];
}

- (void)selectectContactIdentifier:(NSString *) identifier {
    for (int i = 0; i< self.listContacts.count; i++) {
        if ([self.listContacts[i].identifier isEqualToString:identifier]) {
            [self selectectContactAtIndex:i];
            return;
        }
    }
}

- (void)removeSelectedContact:(NSString *)identifier {
    
    ContactViewEntity * contact = [self.listSelectedContacts firstObjectWith:^BOOL(ContactViewEntity*  _Nonnull obj) {
        return [obj.identifier isEqualToString:identifier];
    }];
    
    if ([self.listSelectedContacts containsObject:contact]) {
        [self.listSelectedContacts removeObject:contact];
    }
    
    if (![self.listContacts containsObject:contact]) {
        contact = [self.listContacts firstObjectWith:^BOOL(ContactViewEntity*  _Nonnull obj) {
            return [obj.identifier isEqualToString:identifier];
        }];
    }
    
   
    contact.isChecked = NO;
    int index = (int)[self.listContacts indexOfObject:contact];
    
    self.indexCellNeedUpdateObservable.value = [NSNumber numberWithInt:index];
    
    self.numberOfSelectedContactObservable.value = [NSNumber numberWithInt:(int)self.listSelectedContacts.count];
}

@end
