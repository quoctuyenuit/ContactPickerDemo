//
//  ContactAvatarComponent.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/23/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "ContactViewEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactAvatarComponent : CKCompositeComponent
+ (instancetype)newWithImage:(UIImage * _Nullable) image  label:(NSString *) label gradientBackgroundColor:(NSArray * _Nullable) color size:(CGSize) size;

+ (instancetype)newWithContact:(ContactViewEntity *)contact size:(CGSize) size;

@end

NS_ASSUME_NONNULL_END
