//
//  ContactAvatarNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

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
        self->_image                = [[ASImageNode alloc] init];
        self->_label                = [[ASTextNode alloc] init];
        self->_image.contentMode    = UIViewContentModeScaleAspectFill;
        
        self->_gradient             = [CAGradientLayer layer];
        
        [self->_image setImageModificationBlock:^UIImage * _Nullable(UIImage * _Nonnull image) {
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
- (void)didLoad {
    [super didLoad];
    self->_gradient.frame = CGRectMake(0, 0, self.calculatedSize.width, self.calculatedSize.height);
    self->_gradient.cornerRadius = self->_gradient.bounds.size.width / 2;
    
    [self->_mainBoundNode.layer insertSublayer:self->_gradient atIndex:0];
}
- (void)layoutDidFinish {
    [super layoutDidFinish];
    self.layer.cornerRadius = self.bounds.size.width / 2;
    self->_image.cornerRadius = self->_image.bounds.size.width / 2;
}

- (void)showImage {
    self->_image.alpha = 1;
    self->_label.alpha = 0;
}

- (void)showLabel {
    self->_image.alpha = 1;
    self->_label.alpha = 1;
}

- (void)configWithImage:(UIImage *)image forLabel:(NSString *)label withGradientColor:(NSArray *)color {
//    image = [UIImage imageNamed:@"default_avatar"];
    
    self->_image.image = image;
    self->_label.attributedText = [NSAttributedString attributedStringWithString:label fontSize:FONT_SIZE color: UIColor.whiteColor firstWordColor:nil];
    if (image) {
        [self showImage];
    } else {
        [self showLabel];
    }
    
    self->_gradient.colors = color;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    __weak typeof(self) weakSelf = self;
    
    ASCenterLayoutSpec * textLayout = [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY sizingOptions:ASCenterLayoutSpecSizingOptionDefault child:[self->_label styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.flexGrow = 1;
    }]];
    
    ASLayoutSpec * imageLayout = [ASOverlayLayoutSpec overlayLayoutSpecWithChild: [self->_image styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = weakSelf.calculatedSize;
    }] overlay:textLayout];
    
    return [ASOverlayLayoutSpec overlayLayoutSpecWithChild:[self->_mainBoundNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = weakSelf.calculatedSize;
    }] overlay:imageLayout];
}

@end
