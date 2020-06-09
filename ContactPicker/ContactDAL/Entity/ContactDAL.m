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
@synthesize contactEmails;

@synthesize contactFamilyName;

@synthesize contactID;

@synthesize contactName;

@synthesize contactPhones;

@end
