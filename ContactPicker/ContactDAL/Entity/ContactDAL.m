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
     image: (NSData *) image
     phones:(NSArray<NSString *> *)phone
     emails:(NSArray<NSString *> *)email
{
    self.contactID = contactID;
    self.contactName = givenName;
    self.contactFamilyName = familyName;
    self.contactImage = image;
    self.contactPhones = phone;
    self.contactEmails = email;
    return self;
}

- (id)initWithID:(NSString *)contactID name:(NSString *)name familyName: (NSString *) familyName {
    return [self init:contactID name:name familyName:familyName image: nil phones:nil emails:nil];
}
@end
