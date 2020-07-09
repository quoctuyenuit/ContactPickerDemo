//
//  ContactGlobalConfigure.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/9/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactGlobalConfigure.h"
#import "Utilities.h"


@implementation ContactGlobalConfigure

+ (instancetype)globalConfig {
    static ContactGlobalConfigure * config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[ContactGlobalConfigure alloc] _init];
    });
    return config;
}

- (instancetype)_init {
    _avatarBackgroundColor = UIColor.lightGrayColor;
    _backgroundColor        = UIColor.clearColor;
    _textNameColor          = UIColor.blackColor;
    _textDescriptionColor   = UIColor.darkGrayColor;
    _barActiveColor         = [UIColor appColor];
    _barNonActiveColor      = UIColor.lightGrayColor;
    
    _avatarSize             = CGSizeMake(50, 50);
    
    _mainFontSize           = 17.0f;
    _descriptionFontSize    = 15.0f;
    
    _contactHeight          = 66;
    return self;
}

@end
