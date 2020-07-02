//
//  ContactAvatarNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import "ContactAvatarNode.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "Utilities.h"
#import <UIKit/UIKit.h>

#define DEBUG_MODE      0

#define FONT_SIZE       20

@implementation ContactAvatarNode
- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_mainBoundNode        = [[ASImageNode alloc] init];
        self->_imageNode            = [[ASImageNode alloc] init];
        self->_label                = [[ASTextNode alloc] init];
        self->_imageNode.contentMode    = UIViewContentModeScaleAspectFill;
        
//        _label.attributedText       = [NSAttributedString attributedStringWithString:@"Test" fontSize:FONT_SIZE color: UIColor.whiteColor firstWordColor:nil];
        
        [self->_imageNode setImageModificationBlock:^UIImage * _Nullable(UIImage * _Nonnull image) {
            CGSize profileImageSize = CGSizeMake(AVATAR_IMAGE_HEIGHT, AVATAR_IMAGE_HEIGHT);
            return [image makeCircularImageWithSize:profileImageSize backgroundColor:nil];
        }];
        self.automaticallyManagesSubnodes = YES;
        
#if DEBUG_MODE
        self->_image.backgroundColor    = UIColor.redColor;
        self->_label.backgroundColor    = UIColor.grayColor;
#endif
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)layoutDidFinish {
    [super layoutDidFinish];
    self.layer.cornerRadius = self.bounds.size.width / 2;
    self->_imageNode.cornerRadius = self->_imageNode.bounds.size.width / 2;
}

- (void)configWithImage:(UIImage *)image withTitle:(NSString *)label {
    _imageNode.image = image;
    _label.attributedText = [NSAttributedString attributedStringWithString:label fontSize:FONT_SIZE color: UIColor.whiteColor firstWordColor:nil];
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    __weak typeof(self) weakSelf = self;
    
    ASCenterLayoutSpec * textLayout = [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY sizingOptions:ASCenterLayoutSpecSizingOptionDefault child:[self->_label styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.flexGrow = 10;
    }]];
    
    ASLayoutSpec * imageLayout = [ASOverlayLayoutSpec overlayLayoutSpecWithChild: [self->_imageNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = weakSelf.calculatedSize;
    }] overlay:textLayout];
    
    return [ASOverlayLayoutSpec overlayLayoutSpecWithChild:[self->_mainBoundNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = weakSelf.calculatedSize;
    }] overlay:imageLayout];
}

@end
#endif
