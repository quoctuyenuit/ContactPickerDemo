//
//  ContactBusEntity.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBusEntity.h"

@implementation ContactBusEntity
- (id)initWith:(NSString *)identifier givenName:(NSString *)givenName familyName:(NSString *)familyName {
    self.identifier = identifier;
    self.givenName = givenName;
    self.familyName = familyName;
    return self;
}

- (id)initWithData:(ContactDAL *)contactDAL {
    self.identifier = contactDAL.contactID;
    self.givenName = contactDAL.contactName;
    self.familyName = contactDAL.contactFamilyName;
    return self;
}

- (NSComparisonResult)compare:(ContactBusEntity *)other
{
    return [self.givenName compare:other.givenName];
}
@end
