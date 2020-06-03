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

@interface ListContactViewModel() {
    NSMutableArray *groupOfContacts;
}

@end

@implementation ListContactViewModel
- (id)init {
    self.search = [[DataBinding<NSString*> alloc] initWithValue:@""];
    self.numberOfContact = [[DataBinding<NSNumber*> alloc] initWithValue:0];
    _listContact = [[NSMutableArray alloc] init];
    _listContactOnView = _listContact;
    return self;
}

- (void)getAllContact {
    if ([CNContactStore class]) {
        CNContactStore *addressBook = [[CNContactStore alloc] init];
        
        NSArray *keysToFetch = @[CNContactGivenNameKey,
                                 CNContactPhoneNumbersKey,
                                 CNContactFamilyNameKey,
                                 CNContactImageDataAvailableKey,
                                 CNContactThumbnailImageDataKey];
        
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        
        [addressBook enumerateContactsWithFetchRequest:fetchRequest
                                                 error:nil
                                            usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            
            NSString *name = [NSString stringWithFormat:@"%@ %@", contact.givenName, contact.familyName];
            UIImage *avatar = nil;
            
            if (contact.imageDataAvailable)
            {
                NSData *imageData = contact.imageData;
                avatar = [UIImage imageWithData:imageData];
            }
            
            float activeTime = 300;
            
            ContactViewModel* contactModel = [[ContactViewModel alloc]
                                              initWithModel:[[ContactModel alloc]
                                                             initWithName:name
                                                             avatar: avatar
                                                             activeTime:activeTime]];
            
            [self->_listContact addObject:contactModel];
            self.numberOfContact.value = [NSNumber numberWithInteger:self->_listContact.count];
        }];
    }
}

#pragma mark Public function
- (int)getNumberOfContact {
    return (int)self->_listContactOnView.count;
}

- (ContactViewModel *)getContactAt:(int)index {
    if (index < self->_listContactOnView.count) {
        return self->_listContactOnView[index];
    }
    return nil;
}

- (BOOL)updateListContactWithKey:(NSString *)key {
    if (self->_listContact.count == 0) {
        return false;
    }
    NSUInteger beforeLength = self->_listContactOnView.count;
    self->_listContactOnView = [[NSMutableArray alloc] init];
    for (ContactViewModel* contact in self->_listContact) {
        if ([contact contactStartWith: key])
            [self->_listContactOnView addObject:contact];
    }
    
    return (beforeLength != self->_listContactOnView.count);
}
@end
