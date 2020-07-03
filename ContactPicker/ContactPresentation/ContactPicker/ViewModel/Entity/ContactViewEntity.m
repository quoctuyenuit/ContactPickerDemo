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
- (NSString *) _parseName: (NSString *) givenName familyName:(NSString *) familyName;
@end

@implementation ContactViewEntity

#pragma mark - Helper methods
- (NSString *)_parseName:(NSString *)givenName familyName:(NSString *)familyName {
    return [NSString stringWithFormat:@"%@ %@", givenName, familyName];
}

- (NSString *)keyName {
    NSArray * names = [_fullName.string componentsSeparatedByString:@" "];
    NSString * first = [[names firstObject] substringToIndex: 1];
    NSString * last = [[names lastObject] substringToIndex: 1];

    return [NSString stringWithFormat:@"%@%@", first ? first : @"", last ? last : @""];
}

#pragma mark - Public methods
- (id) initWithIdentifier: (NSString *) identifier
                givenName: (NSString *) givenName
               familyName: (NSString *) familyName
                    phone: (NSString *) phone
                isChecked: (BOOL) isChecked {
    _identifier         = identifier;
    _isCheckObservable  = [[DataBinding alloc] initWithValue:[NSNumber numberWithBool:isChecked]];
    _isChecked          = isChecked;
    
    
    NSString * fullName = [self _parseName:givenName familyName:familyName];
    _fullName   = [NSAttributedString attributedStringWithString: fullName font:[UIFont systemFontOfSize:CONTACT_FONT_SIZE weight:UIFontWeightRegular]  color:[UIColor contactNameColor] firstWordColor:nil];
    _phone      = [NSAttributedString attributedStringWithString: phone font:[UIFont systemFontOfSize:CONTACT_DESCRIPTION_FONT_SIZE weight:UIFontWeightRegular] color:[UIColor contactDescriptionColor] firstWordColor:nil];
    return self;
}

- (id)initWithBusEntity:(id<ContactBusEntityProtocol>)entity {
    NSString * firstPhone = entity.phones.firstObject;
    return [self initWithIdentifier:entity.identifier
                          givenName:entity.givenName
                         familyName:entity.familyName
                              phone:firstPhone isChecked:NO];
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    _isCheckObservable.value = [NSNumber numberWithBool:isChecked];
}

- (void)updateContactWithBus:(id<ContactBusEntityProtocol>)entity {
    NSString * fullName = [self _parseName:entity.givenName familyName:entity.familyName];
    NSString * firstPhone = entity.phones.firstObject;
    _fullName   = [NSAttributedString attributedStringWithString: fullName fontSize:CONTACT_FONT_SIZE color:[UIColor contactNameColor] firstWordColor:nil];
    _phone      = [NSAttributedString attributedStringWithString: firstPhone fontSize:CONTACT_DESCRIPTION_FONT_SIZE color:[UIColor contactDescriptionColor] firstWordColor:nil];
}

- (void)updateContact:(ContactViewEntity *)entity {
    _fullName           = entity.fullName;
    _isChecked          = entity.isChecked;
    _isCheckObservable  = entity.isCheckObservable;
}

- (BOOL)isEqualWithBusEntity:(id<ContactBusEntityProtocol>)entity {
    NSString * fullNameString = _fullName.string;
    NSString * entityFullName = [self _parseName:entity.givenName familyName:entity.familyName];
    return ([fullNameString isEqualToString:entityFullName]);
}
@end
