//
//  ContactAvatarNode.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactAvatarNode : ASDisplayNode {
    ASDisplayNode   * _mainBoundNode;
    ASImageNode     * _image;
    ASTextNode      * _label;
    CAGradientLayer * _gradient;
}

- (instancetype) init;
- (void) showImage;
- (void) showLabel;
- (void) configWithImage: (UIImage * _Nullable) image forLabel: (NSString *) label withGradientColor: (NSArray * _Nullable) color;
@end

NS_ASSUME_NONNULL_END
#endif
