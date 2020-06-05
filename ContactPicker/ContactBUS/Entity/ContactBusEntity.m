//
//  ContactBusEntity.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBusEntity.h"

@implementation ContactBusEntity
- (id)initWith:(NSString *)contactID name:(NSString *)name {
    self.contactID = contactID;
    self.contactName = name;
    return self;
}

- (id)initWithData:(ContactDAL *)contactDAL {
    self.contactName = [NSString stringWithFormat:@"%@ %@", contactDAL.contactName, contactDAL.contactFamilyName];
    self.contactID = contactDAL.contactID;
    return self;
}

- (BOOL)fitWithName:(NSString *)name {
    if ([name isEqualToString:@""]) {
        return YES;
    }
    return [[self.contactName lowercaseString] hasPrefix:[name lowercaseString]];
}
@end
