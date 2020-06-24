//
//  ContactAvatarComponent.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/23/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactAvatarComponent.h"
#import <ComponentKit/ComponentKit.h>
#import "ContactAvatarView.h"
#import "Utilities.h"

@implementation ContactAvatarComponent

+ (instancetype)newWithImage:(UIImage *)image label:(NSString *)label gradientBackgroundColor:(NSArray *)color size:(CGSize) size {
    CKComponentScope scope(self);
    CKComponent * overlay = image ?
    [CKComponent newWithView:{[UIImageView class], {
        {@selector(setImage:), image},
        {@selector(setContentMode:), UIImageResizingModeStretch},
        {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), @10}
    }} size:{.width = size.width, .height = size.height}] :
    [CKCenterLayoutComponent newWithCenteringOptions:CKCenterLayoutComponentCenteringY sizingOptions:CKCenterLayoutComponentSizingOptionDefault
                                               child:[CKLabelComponent newWithLabelAttributes:{
        .string     = label,
        .alignment  = NSTextAlignmentCenter,
        .color      = UIColor.whiteColor,
        .font       = [UIFont systemFontOfSize:20]
    } viewAttributes:{
        {@selector(setBackgroundColor:), [UIColor clearColor]},
        {@selector(setUserInteractionEnabled:), @NO}
    } size:{}] size:{.width = size.width, .height = size.height}];
    
    return [super newWithComponent:
            [CKOverlayLayoutComponent newWithComponent:
             [CKComponent newWithView:{[UIView class], {
        
        {CKComponentViewAttribute::LayerAttribute(@selector(addSublayer:)), [CAGradientLayer gradientWithSize:CGRectMake(0, 0, size.width, size.height)
                                                                                                       colors:color]}
    }}
                                 size:{.width = size.width, .height = size.height}] overlay:overlay]];
}

+ (instancetype)newWithContact:(ContactViewEntity *)contact size:(CGSize) size {
    CKComponentScope scope(self);
    NSString * firstString = contact.givenName.length > 0 ? [contact.givenName substringToIndex:1] : @"";
    NSString * secondString = contact.familyName.length > 0 ? [contact.familyName substringToIndex:1] : @"";
    NSString * keyName = [NSString stringWithFormat:@"%@%@", firstString, secondString];
    
    return [self newWithImage:contact.avatar label:keyName gradientBackgroundColor:contact.backgroundColor size:size];
}
@end
