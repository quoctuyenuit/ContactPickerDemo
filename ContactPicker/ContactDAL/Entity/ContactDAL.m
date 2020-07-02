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

- (id)initWithIdentifier:(NSString *)contactID
                    name:(NSString *)givenName
              familyName:(NSString *)familyName
                  phones:(NSArray<NSString *> *)phones
                  emails:(NSArray<NSString *> *)emails
{
    self.identifier     = contactID;
    self.givenName      = givenName;
    self.familyName     = familyName;
    self.contactPhones  = [[NSMutableArray alloc] initWithArray:phones];
    self.contactEmails  = [[NSMutableArray alloc] initWithArray:emails];
    return self;
}

@synthesize contactEmails;

@synthesize familyName;

@synthesize identifier;

@synthesize givenName;

@synthesize contactPhones;

@end
