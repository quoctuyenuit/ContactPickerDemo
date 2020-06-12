//
//  ContactViewModel.m
//  ContactPicker
//
//  Created by LAP11963 on 6/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactViewEntity.h"
#import <UIKit/UIKit.h>
#import "GradientColors.h"

@interface ContactViewEntity()
- (NSString *) parseName: (NSString *) givenName familyName:(NSString *) familyName;
- (UIColor *) randomColor;
@end

@implementation ContactViewEntity

- (id)initWithIdentifier:(NSString *)identifier
               givenName:(NSString * _Nullable)givenName
              familyName:(NSString * _Nullable)familyName
             description:(NSString * _Nullable)description
                  avatar:(UIImage * _Nullable)image
               isChecked:(BOOL)isChecked {
    
    self.identifier = identifier;
    self.givenName = givenName;
    self.familyName = familyName;
    self.contactDescription = description;
    self.avatar = image;
    self.isChecked = isChecked;
    self.backgroundColor = [[GradientColors instantiate] randomColor];
    return self;
}

- (id)initWithBusEntity:(ContactBusEntity *)entity {
    return [self initWithIdentifier:entity.identifier givenName:entity.givenName familyName:entity.familyName description:@"" avatar:nil isChecked:NO];
}

- (NSString *) fullName {
    return [self parseName:self.givenName familyName:self.familyName];
}

- (void)updateContactWithBus:(ContactBusEntity *)entity {
    self.givenName = entity.givenName;
    self.familyName = entity.familyName;
}

- (void)updateContact:(ContactViewEntity *)entity {
    self.givenName = entity.givenName;
    self.familyName = entity.familyName;
    self.isChecked = entity.isChecked;
    self.avatar = entity.avatar;
    self.backgroundColor = entity.backgroundColor;
    self.contactDescription = entity.contactDescription;
}

- (NSString *)parseName:(NSString *)givenName familyName:(NSString *)familyName {
    return [NSString stringWithFormat:@"%@ %@", givenName, familyName];
}

- (BOOL)contactHasPrefix:(NSString *)key {
    if ([key isEqualToString:@""]) {
        return true;
    }
    return [[self.fullName lowercaseString] hasPrefix: [key lowercaseString]];
}

- (BOOL)isEqualWithBusEntity:(ContactBusEntity *)entity {
    return ([self.givenName isEqualToString:entity.givenName] &&
            [self.familyName isEqualToString:entity.familyName]);
}

- (UIColor *) randomColor {
    return [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
}

- (BOOL)isEqual:(ContactViewEntity *)other
{
    if (other == self) {
        return YES;
    } else {
        return [self.identifier isEqualToString:other.identifier];
    }
}

- (NSUInteger)hash
{
    return [self.identifier hash];
}

@end
