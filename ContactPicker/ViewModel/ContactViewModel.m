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
}

- (id) finalizeInit;
- (ContactViewEntity *) parseContactEntity: (ContactBusEntity *) entity;
@end

@implementation ContactViewModel

@synthesize listContact = _listContact;

@synthesize listContactOnView = _listContactOnView;

@synthesize search;

@synthesize updateContacts;

- (id)initWithBus:(id<ContactBusProtocol>)bus {
    self->_contactBus = bus;
    self = [self finalizeInit];
    return self;
}

- (id)finalizeInit {
    self->_listContact = [[NSMutableArray alloc] init];
    self->_listContactOnView = _listContact;
    
    self.search = [[DataBinding<NSString *> alloc] initWithValue:@""];
    self.updateContacts = [[DataBinding<NSArray *> alloc] initWithValue:nil];
    
    __weak ContactViewModel * weakSelf = self;
    
    self->_contactBus.contactChangedObservable = ^(NSArray * contactsUpdated) {
        
        NSMutableArray * listIndexNeedUpdate = [[NSMutableArray alloc] init];
        NSArray * contactsViewModelUpdated = [contactsUpdated map:^ContactViewEntity* _Nonnull(ContactBusEntity*  _Nonnull obj) {
            return [weakSelf parseContactEntity:obj];
        }];
        
        [contactsViewModelUpdated enumerateObjectsUsingBlock:^(ContactViewEntity*  _Nonnull newEntity, NSUInteger idx, BOOL * _Nonnull stop) {
            
            for (int i = 0; i < weakSelf.listContactOnView.count ; i++ ) {
                ContactViewEntity * oldEntity = weakSelf.listContactOnView[i];
                if ([oldEntity.identifier isEqualToString:newEntity.identifier] && ![oldEntity isEqual:newEntity]) {
                    [listIndexNeedUpdate addObject:[NSNumber numberWithInt:i]];
                    weakSelf.listContactOnView[i] = newEntity;
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
    [
     self->_contactBus getImageFromId:entity.identifier completion:^(NSData * imageData) {
        UIImage * image = [UIImage imageWithData:imageData];
        viewEntity.avatar = image;
        if (viewEntity.waitImageToExcuteQueue) {
            viewEntity.waitImageToExcuteQueue(image, entity.identifier);
        }
    }];
    return viewEntity;
}

#pragma mark Public function
- (void)requestPermission:(void (^)(BOOL, NSError *))completion {
    [self->_contactBus requestPermission:completion];
}

- (void)loadContacts:(void (^)(BOOL isSuccess, int numberOfContacts))completion {
    [self->_contactBus loadContacts:^(NSError * error) {
        if (error) {
            completion(NO, 0);
            [Logging error:[NSString stringWithFormat:@"Load contact failt, error: %@", error.localizedDescription]];
        } else {
            [self loadBatchOfContacts:completion];
        }
    }];
}

- (void)loadBatchOfContacts:(void (^)(BOOL isSuccess, int numberOfContacts))completion {
    [self->_contactBus loadBatchOfContacts:^(NSArray<ContactBusEntity *> * listContactBusEntity, NSError * error) {
        if (error) {
            completion(NO, 0);
            [Logging error:[NSString stringWithFormat:@"Load batch contact failt, error: %@", error.localizedDescription]];
        } else {
            NSArray * batchOfContact = [listContactBusEntity map:^ContactViewEntity* _Nonnull(ContactBusEntity*  _Nonnull obj) {
                return [self parseContactEntity:obj];
            }];
            
            [self->_listContact addObjectsFromArray:batchOfContact];
            completion(YES, (int)batchOfContact.count);
        }
    }];
}

- (int)getNumberOfContacts {
    return (int)self->_listContactOnView.count;
}

- (ContactViewEntity *)getContactAt:(int)index {
    if (index < self->_listContactOnView.count) {
        return self->_listContactOnView[index];
    }
    return nil;
}

- (void)searchContactWithKeyName:(NSString *)key completion:(void (^)(BOOL))handler {
    if (self->_listContact.count == 0) {
        handler(NO);
        return;
    }
    NSUInteger beforeLength = self->_listContactOnView.count;
    if ([key isEqualToString:@""]) {
        self->_listContactOnView = self->_listContact;
        handler(beforeLength != self->_listContactOnView.count);
        return;
    }
    
    [self->_contactBus searchContactByName:key completion:^(NSArray * listContactBusEntity, NSError * error) {
        if (error) {
            handler(NO);
            [Logging error:[NSString stringWithFormat:@"Load batch with error in search, error: %@", error.localizedDescription]];
        } else {
            NSArray * batchOfContact = [listContactBusEntity map:^ContactViewEntity* _Nonnull(ContactBusEntity*  _Nonnull obj) {
                return [self parseContactEntity:obj];
            }];
            
            self->_listContactOnView = [[NSMutableArray alloc] initWithArray:batchOfContact];
            
            handler(YES);
        }
    }];
}
@end
