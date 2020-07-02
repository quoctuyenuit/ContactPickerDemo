//
//  CheckBoxComponent.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_COMPONENTKIT
#import "CheckBoxComponent.h"
#import <ComponentKit/ComponentKit.h>
#import <ComponentKit/CKComponentSubclass.h>

#define CHECK_IMAGE_NAME    @"checked_img"
#define UNCHECK_IMAGE_NAME  @"unchecked_img"

@implementation CheckBoxComponent

+ (instancetype)newWithSize:(CGSize) size state:(BOOL) isChecked {
    CKComponentScope scope(self);
//    const BOOL _state = [scope.state() boolValue];
    
    NSString * imageName = isChecked ? CHECK_IMAGE_NAME : UNCHECK_IMAGE_NAME;
    
    CheckBoxComponent * c = [super newWithComponent: [CKButtonComponent newWithAction:{scope, @selector(checkAction:event:)} options:{
        .backgroundImages   = {{UIControlStateNormal, [UIImage imageNamed:imageName]}},
        .size               = {.width = size.width, .height = size.height}
    }]];
    
    if (c) {
        c->_isChecked = isChecked;
    }
//    c.isChecked = isChecked;

    return c;
}

- (void)checkAction:(CKButtonComponent *) sender event:(UIEvent *) event {
    _isChecked = !_isChecked;
    [self updateState:^(NSNumber *oldState) {
        return [oldState boolValue] ? @NO : @YES;
    } mode:CKUpdateModeSynchronous];
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    [self updateState:^(NSNumber *oldState) {
        return [NSNumber numberWithBool:isChecked];
    } mode:CKUpdateModeSynchronous];
}

@end
#endif
