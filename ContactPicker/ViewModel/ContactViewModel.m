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
    NSArray * backupListContact;
}

- (id) finalizeInit;
- (ContactViewEntity *) parseContactEntity: (ContactBusEntity *) entity;
@end

@implementation ContactViewModel

@synthesize listContacts = _listContacts;

@synthesize search;

@synthesize updateContacts;

- (id)initWithBus:(id<ContactBusProtocol>)bus {
    self->_contactBus = bus;
    self = [self finalizeInit];
    self->_contactIsLoaded = NO;
    return self;
}

- (id)finalizeInit {
    self.listContacts = [[NSMutableArray alloc] init];
    
    self.search = [[DataBinding<NSString *> alloc] initWithValue:@""];
    self.updateContacts = [[DataBinding<NSArray *> alloc] initWithValue:nil];
    
    __weak ContactViewModel * weakSelf = self;
    
    self->_contactBus.contactChangedObservable = ^(NSArray * contactsUpdated) {
        
        NSMutableArray * listIndexNeedUpdate = [[NSMutableArray alloc] init];
        NSArray * contactsViewModelUpdated = [contactsUpdated map:^ContactViewEntity* _Nonnull(ContactBusEntity*  _Nonnull obj) {
            return [weakSelf parseContactEntity:obj];
        }];
        
        [contactsViewModelUpdated enumerateObjectsUsingBlock:^(ContactViewEntity*  _Nonnull newEntity, NSUInteger idx, BOOL * _Nonnull stop) {
            
            for (int i = 0; i < weakSelf.listContacts.count ; i++ ) {
                ContactViewEntity * oldEntity = weakSelf.listContacts[i];
                if ([oldEntity.identifier isEqualToString:newEntity.identifier] && ![oldEntity isEqual:newEntity]) {
                    [listIndexNeedUpdate addObject:[NSNumber numberWithInt:i]];
                    weakSelf.listContacts[i] = newEntity;
                }
            }
        }];
        
        weakSelf.updateContacts.value = listIndexNeedUpdate;
    };
    
    return self;
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

- (void)addContacts:(NSArray *)batchOfContact {
    [batchOfContact enumerateObjectsUsingBlock:^(ContactViewEntity *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (ContactViewEntity * backupObj in self->backupListContact) {
            if ([backupObj.identifier isEqualToString:obj.identifier]) {
                obj.isChecked = backupObj.isChecked;
            }
        }
    }];
    [self.listContacts addObjectsFromArray:batchOfContact];
}

- (void)loadBatchOfDetailedContacts:(void (^)(BOOL isSuccess, NSError * error, int numberOfContacts))completion {
    [self->_contactBus loadBatchOfDetailedContacts:^(NSArray<ContactBusEntity *> * listContactBusEntity, NSError * error) {
        if (error) {
            completion(NO, error, 0);
            [Logging error:[NSString stringWithFormat:@"Load batch contact failt, error: %@", error.localizedDescription]];
        } else {
            NSArray * batchOfContact = [listContactBusEntity map:^ContactViewEntity* _Nonnull(ContactBusEntity*  _Nonnull obj) {
                return [self parseContactEntity:obj];
            }];
            
            [self addContacts:batchOfContact];
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
        [self refresh];
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

- (void)refresh {
    self->backupListContact = self.listContacts;
    self.listContacts = [[NSMutableArray alloc] init];
}
@end
