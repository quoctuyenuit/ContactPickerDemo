//
//  ListContactViewModel.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ListContactViewModel.h"
#import "ContactViewModel.h"
#import <Contacts/Contacts.h>
#import "NSArrayExtension.h"

@interface ListContactViewModel() {
}

- (id) finalizeInit;
- (ContactViewModel *) parseContactEntity: (ContactBusEntity *) entity;
@end

@implementation ListContactViewModel

@synthesize listContact = _listContact;
@synthesize listContactOnView = _listContactOnView;

- (id)initWithBus:(id<ContactBusProtocol>)bus {
    self->_contactBus = bus;
    self = [self finalizeInit];
    return self;
}

- (id)finalizeInit {
    self.search = [[DataBinding<NSString *> alloc] initWithValue:@""];
    self.updateContacts = [[DataBinding<NSArray *> alloc] initWithValue:nil];
    
    [self refreshListContact];
    __weak ListContactViewModel * weakSelf = self;
    
    self->_contactBus.contactChangedObservable = ^(NSArray * contactsUpdated) {
        
        NSMutableArray * listIndexNeedUpdate = [[NSMutableArray alloc] init];
        NSArray * contactsViewModelUpdated = [contactsUpdated map:^ContactViewModel* _Nonnull(ContactBusEntity*  _Nonnull obj) {
            return [weakSelf parseContactEntity:obj];
        }];
        
        [contactsViewModelUpdated enumerateObjectsUsingBlock:^(ContactViewModel*  _Nonnull newModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            for (int i = 0; i < weakSelf.listContactOnView.count ; i++ ) {
                ContactViewModel * oldModel = weakSelf.listContactOnView[i];
                if ([oldModel.identifier isEqualToString:newModel.identifier] && ![oldModel isEqual:newModel]) {
                    [listIndexNeedUpdate addObject:[NSNumber numberWithInt:i]];
                    weakSelf.listContactOnView[i] = newModel;
                }
            }
        }];
        
        weakSelf.updateContacts.value = listIndexNeedUpdate;
    };
    
    return self;
}


- (ContactViewModel *)parseContactEntity:(ContactBusEntity *)entity {
    ContactViewModel *model =  [[ContactViewModel alloc] initWithIdentifier:entity.contactID name:entity.contactName description:@"temp" avatar: [UIImage imageWithData: entity.contactImage]];
    
    return model;
}


- (void)refreshListContact {
    self->_listContact = [[NSMutableArray alloc] init];
    self->_listContactOnView = _listContact;
}

- (void)loadContacts:(ViewHandler)completion {
    [self refreshListContact];
    [self->_contactBus loadContacts:^(BOOL isSuccess) {
        if (isSuccess) {
            [self loadBatch:completion];
        }
    }];
}

- (void)loadBatch:(ViewHandler)completion {
    [self->_contactBus loadBatch:^(NSArray<ContactBusEntity *> * listContactBusEntity) {
        NSArray * batchOfContact = [listContactBusEntity map:^ContactViewModel* _Nonnull(ContactBusEntity*  _Nonnull obj) {
            return [self parseContactEntity:obj];
        }];
        
        [self->_listContact addObjectsFromArray:batchOfContact];
        completion(YES, (int)batchOfContact.count);
    }];
}

#pragma mark Public function
- (int)getNumberOfContacts {
    return (int)self->_listContactOnView.count;
}

- (ContactViewModel *)getContactAt:(int)index {
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
    
    [self->_contactBus searchContactByName:key completion:^(NSArray * listContactBusEntity) {
        NSArray * batchOfContact = [listContactBusEntity map:^ContactViewModel* _Nonnull(ContactBusEntity*  _Nonnull obj) {
            return [self parseContactEntity:obj];
        }];
        
        self->_listContactOnView = [[NSMutableArray alloc] init];
        
        self->_listContactOnView = [NSMutableArray arrayWithArray:batchOfContact];
        
        handler(YES);
    }];
}
@end
