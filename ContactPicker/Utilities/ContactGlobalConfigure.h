//
//  ContactGlobalConfigure.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/9/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactGlobalConfigure : NSObject
+ (instancetype)globalConfig;

#pragma mark - Colors
@property(nonatomic, readonly) UIColor *avatarBackgroundColor;
@property(nonatomic, readonly) UIColor *backgroundColor;
@property(nonatomic, readonly) UIColor *textNameColor;
@property(nonatomic, readonly) UIColor *textDescriptionColor;
@property(nonatomic, readonly) UIColor *barActiveColor;
@property(nonatomic, readonly) UIColor *barNonActiveColor;

#pragma mark - CGSize
@property(nonatomic, readonly) CGSize  avatarSize;

#pragma mark - Font
@property(nonatomic, readonly) CGFloat mainFontSize;
@property(nonatomic, readonly) CGFloat descriptionFontSize;

@property(nonatomic, readonly) CGFloat contactHeight;
@end

NS_ASSUME_NONNULL_END
