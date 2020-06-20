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

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.givenName, self.familyName];
}

- (id)initWithIdentifier:(NSString *)contactID
                    name:(NSString *)givenName
              familyName:(NSString *)familyName
                  phones:(NSArray<NSString *> *)phone
                  emails:(NSArray<NSString *> *)email
               imageData:(NSData *)imageData
{
    self.identifier          = contactID;
    self.givenName        = givenName;
    self.familyName  = familyName;
    self.contactPhones      = phone;
    self.contactEmails      = email;
    self.imageData          = imageData;
    return self;
}

- (id)initWithID:(NSString *)contactID name:(NSString *)name familyName: (NSString *) familyName {
    return [self initWithIdentifier:contactID name:name familyName:familyName phones:nil emails:nil imageData: nil];
}
@synthesize contactEmails;

@synthesize familyName;

@synthesize identifier;

@synthesize givenName;

@synthesize contactPhones;

@synthesize imageData;

@end
