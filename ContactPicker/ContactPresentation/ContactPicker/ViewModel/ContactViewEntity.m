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
#import "Utilities.h"

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
    
    _identifier         = identifier;
    _givenName          = givenName;
    _familyName         = familyName;
    _contactDescription = description;
    _avatar             = image;
    _isChecked          = isChecked;
    _backgroundColor    = [[GradientColors instantiate] colorForKey:_identifier];
    _isCheckObservable  = [[DataBinding alloc] initWithValue:@NO];
    return self;
}

- (void)setAvatar:(UIImage *)avatar {
    _avatar = avatar;
    if (_waitImageToExcuteQueue) {
        _waitImageToExcuteQueue(_avatar, _identifier);
    }
    if (_waitImageSelectedToExcuteQueue) {
        _waitImageSelectedToExcuteQueue(_avatar, _identifier);
    }
}

- (id)initWithBusEntity:(ContactBusEntity *)entity {
    UIImage * imageData = [UIImage imageWithData:entity.imageData];
    return [self initWithIdentifier:entity.identifier givenName:entity.givenName familyName:entity.familyName description:@"" avatar:imageData isChecked:NO];
}

- (NSString *) fullName {
    return [self parseName:_givenName familyName:_familyName];
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    _isCheckObservable.value = [NSNumber numberWithBool:isChecked];
}

- (void)updateContactWithBus:(ContactBusEntity *)entity {
    _givenName  = entity.givenName;
    _familyName = entity.familyName;
}

- (void)updateContact:(ContactViewEntity *)entity {
    _givenName          = entity.givenName;
    _familyName         = entity.familyName;
    _isChecked          = entity.isChecked;
    _avatar             = entity.avatar;
    _backgroundColor    = entity.backgroundColor;
    _contactDescription = entity.contactDescription;
    _isCheckObservable  = entity.isCheckObservable;
}

- (NSString *)parseName:(NSString *)givenName familyName:(NSString *)familyName {
    return [NSString stringWithFormat:@"%@ %@", givenName, familyName];
}

- (BOOL)contactHasPrefix:(NSString *)key {
    if ([key isEqualToString:@""]) {
        return true;
    }
    return [[_fullName lowercaseString] hasPrefix: [key lowercaseString]];
}

- (BOOL)isEqualWithBusEntity:(ContactBusEntity *)entity {
    return ([_givenName isEqualToString:entity.givenName] &&
            [_familyName isEqualToString:entity.familyName]);
}

- (UIColor *) randomColor {
    return [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
}

- (NSUInteger)hash
{
    return [_identifier hash];
}

- (NSAttributedString *)fullNameAttributedStringFontSize:(CGFloat)fontSize {
    return [NSAttributedString attributedStringWithString:self.fullName fontSize:fontSize color:[UIColor contactNameColor] firstWordColor:nil];
}

- (NSAttributedString *)descriptionAttributedStringFontSize:(CGFloat)fontSize {
    return [NSAttributedString attributedStringWithString:_contactDescription fontSize:fontSize color:[UIColor contactNameColor] firstWordColor:nil];
}

@end
