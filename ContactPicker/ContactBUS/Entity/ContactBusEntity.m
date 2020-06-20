//
//  ContactBusEntity.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBusEntity.h"

@implementation ContactBusEntity
- (id)initWithIdentifier:(NSString *)identifier givenName:(NSString *)givenName familyName:(NSString *)familyName imageData:(NSData * _Nullable)imageData {
    self.identifier     = identifier;
    self.givenName      = givenName;
    self.familyName     = familyName;
    self.imageData      = imageData;
    
    return self;
}

- (id)initWithData:(ContactDAL *)contactDAL {
    return [self initWithIdentifier:contactDAL.identifier givenName:contactDAL.givenName familyName:contactDAL.familyName imageData:contactDAL.imageData];
}

- (NSComparisonResult)compare:(ContactBusEntity *)other
{
    return [self.givenName compare:other.givenName];
}
@end
