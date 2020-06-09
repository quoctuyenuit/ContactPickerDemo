//
//  ContactModel.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#ifndef ContactDAL_h
#define ContactDAL_h

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import "ContactDALProtocol.h"


@interface ContactDAL : NSObject<ContactDALProtocol>


- (id)init: (NSString *) contactID
      name: (NSString *) givenName
familyName: (NSString *) familyName
     phones: (NSArray<NSString *> *) phone
     emails: (NSArray<NSString *> *) email;

- (id) initWithID: (NSString *) contactID
             name: (NSString *) name
       familyName: (NSString *) familyName;

@end

#endif /* ContactDAL_h */
