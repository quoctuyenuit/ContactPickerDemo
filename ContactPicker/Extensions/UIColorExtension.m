//
//  UIColorExtension.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/11/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "UIColorExtension.h"
#import <UIKit/UIKit.h>

@implementation UIColor(extension)
+ (UIColor *)colorFromHex:(NSString *)hex {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
@end
