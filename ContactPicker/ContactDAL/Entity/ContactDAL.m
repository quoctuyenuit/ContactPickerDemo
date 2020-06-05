//
//  ContactModel.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactDAL.h"
#import <Contacts/Contacts.h>

@implementation ContactDAL

- (id)init:(NSString *)contactID
      name:(NSString *)givenName
familyName:(NSString *)familyName
     phones:(NSArray<NSString *> *)phone
     emails:(NSArray<NSString *> *)email
{
    self.contactID = contactID;
    self.contactName = givenName;
    self.contactFamilyName = familyName;
    self.contactPhones = phone;
    self.contactEmails = email;
    return self;
}

- (id)initWithID:(NSString *)contactID name:(NSString *)name familyName: (NSString *) familyName {
    return [self init:contactID name:name familyName:familyName phones:nil emails:nil];
}

- (BOOL)isEqual:(ContactDAL *)other
{
    if (other == self) {
        return YES;
    } else {
        return  ([self.contactID isEqualToString:other.contactID] &&
                 [self.contactName isEqualToString:other.contactName] &&
                 [self.contactFamilyName isEqualToString:other.contactFamilyName] &&
                 [self.contactPhones isEqualToArray:other.contactPhones] &&
                 [self.contactEmails isEqualToArray:other.contactEmails]);
    }
}

- (NSUInteger)hash
{
    return [self.contactName hash];
}

@end
