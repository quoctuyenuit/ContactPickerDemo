//
//  ContactBusEntity.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactDALProtocol.h"
#import "ContactBusEntityProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactBusEntity : NSObject <ContactBusEntityProtocol>
- (id) initWithIdentifier: (NSString *) identifier
                givenName: (NSString*) givenName
               familyName: (NSString *) familyName
                   phones: (NSArray<NSString *> *) phones;

- (id) initWithData: (id<ContactDALProtocol>) contactDAL;

- (BOOL)compareWithNameQuery:(NSString *) query;
@end

NS_ASSUME_NONNULL_END
