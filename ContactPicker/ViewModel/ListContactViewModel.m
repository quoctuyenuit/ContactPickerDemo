//
//  ListContactViewModel.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ListContactViewModel.h"
#import "ContactViewModel.h"
#import "ContactModel.h"
#import <Contacts/Contacts.h>
#import "NSArrayExtension.h"

@interface ListContactViewModel() {
    NSMutableArray *groupOfContacts;
}

- (id) finalizeInit;
@end

@implementation ListContactViewModel

- (id)initWithBus:(id<ContactBusProtocol>)bus {
    self->_contactBus = bus;
    self = [self finalizeInit];
    return self;
}

- (id)finalizeInit {
    self.search = [[DataBinding<NSString*> alloc] initWithValue:@""];
    
    self->_listContact = [[NSMutableArray alloc] init];
    self->_listContactOnView = _listContact;
    return self;
}

- (void)loadContacts:(ViewHandler)completion {
    [self->_contactBus loadContacts:^(BOOL isSuccess) {
        completion(isSuccess, 0);
    }];
}

- (void)loadBatch:(ViewHandler)completion {
    [self->_contactBus loadBatch:^(NSArray<ContactBusEntity *> * listContactBusEntity) {
        NSArray * batchOfContact = [listContactBusEntity map:^ContactViewModel* _Nonnull(ContactBusEntity*  _Nonnull obj) {
            ContactViewModel *entity =  [[ContactViewModel alloc] initWithIdentifier:obj.contactID name:obj.contactName description:@"temp"];
            
            //            Request contact image
            [self->_contactBus getImageFor:entity.identifier completion:^(UIImage *image) {
                entity.avatar = image;
                if (entity.waitImageToExcuteQueue != nil)
                {
                    entity.waitImageToExcuteQueue(image, entity.identifier);
                }
            }];
            
            
            return entity;
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
            ContactViewModel *entity =  [[ContactViewModel alloc] initWithIdentifier:obj.contactID name:obj.contactName description:@"temp"];
            
            //            Request contact image
            [self->_contactBus getImageFor:entity.identifier completion:^(UIImage *image) {
                entity.avatar = image;
                if (entity.waitImageToExcuteQueue != nil)
                {
                    entity.waitImageToExcuteQueue(image, entity.identifier);
                }
            }];
            
            
            return entity;
        }];
        
        self->_listContactOnView = [[NSMutableArray alloc] init];
        
        self->_listContactOnView = [NSMutableArray arrayWithArray:batchOfContact];
        
        handler(YES);
    }];
    
//    self->_listContactOnView = [[NSMutableArray alloc] init];
//    for (ContactViewModel* contact in self->_listContact) {
//        if ([contact contactHasPrefix: key])
//            [self->_listContactOnView addObject:contact];
//    }
//
//    return (beforeLength != self->_listContactOnView.count);
}
@end
