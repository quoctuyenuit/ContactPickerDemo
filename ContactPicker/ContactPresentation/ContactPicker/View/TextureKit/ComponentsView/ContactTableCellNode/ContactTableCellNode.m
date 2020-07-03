//
//  ContactCellNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import "ContactTableCellNode.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import "Utilities.h"
#import "ContactAvatarNode.h"
#import "CheckBoxNode.h"
#import "ImageManager.h"

#define DEBUG_MODE              0

#define SPACE_BETWEEN_ELEMENT   0
#define TOP_PADDING             8
#define BOTTOM_PADDING          8
#define LEFT_PADDING            16
#define RIGHT_PADDING           8
#define InsetForAvatar          UIEdgeInsetsMake(TOP_PADDING, LEFT_PADDING, BOTTOM_PADDING, 0)
#define InsetForCheckBox        UIEdgeInsetsMake(0, LEFT_PADDING, 0, 0)
#define InsetForText            UIEdgeInsetsMake(0, LEFT_PADDING, 0, 0)
#define CHECK_BOX_HEIGHT        25


@implementation ContactTableCellNode {
    ContactViewEntity   * _contact;
    CheckBoxNode        * _checkBox;
    ContactAvatarNode   * _avatar;
    ASTextNode          * _contactNameLabel;
    ASTextNode          * _contactDescriptionLabel;
}

- (instancetype)initWithContact:(ContactViewEntity *)contact {
    self = [super init];
    
    if (self) {
        _contact                  = contact;
        _avatar                   = [[ContactAvatarNode alloc] init];
        _contactNameLabel         = [[ASTextNode alloc] init];
        _contactDescriptionLabel  = [[ASTextNode alloc] init];
        _checkBox                 = [[CheckBoxNode alloc] init];
        
        _avatar.style.preferredSize               = CGSizeMake(AVATAR_IMAGE_HEIGHT, AVATAR_IMAGE_HEIGHT);
        _checkBox.style.preferredSize             = CGSizeMake(CHECK_BOX_HEIGHT, CHECK_BOX_HEIGHT);
        _checkBox.userInteractionEnabled          = NO;
        
        self.automaticallyManagesSubnodes = YES;
        [self configForModel:_contact];
#if DEBUG_MODE
        _avatar.backgroundColor                   = UIColor.greenColor;
        _contactNameLabel.backgroundColor         = UIColor.grayColor;
        _contactDescriptionLabel.backgroundColor  = UIColor.blueColor;
#endif
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
//    CheckBox layout
    ASLayoutSpec * checkBoxLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:InsetForCheckBox
                                                                           child:
                                     [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                                                                sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                                                        child:_checkBox]];
    
//    Avatar layout
    ASLayoutSpec * avatarLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:InsetForAvatar
                                                                         child: [_avatar styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = CGSizeMake(AVATAR_IMAGE_HEIGHT, AVATAR_IMAGE_HEIGHT);
    }]];
    
//    Text layout
    ASLayoutSpec * textLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:InsetForText child:[ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                        spacing:5
                                                                 justifyContent:ASStackLayoutJustifyContentCenter
                                                                     alignItems:ASStackLayoutAlignItemsStart
                                                                       children: @[[_contactNameLabel styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                                                                           style.flexShrink = 1.0;
                                                                       }],
                                                                                                                                              [_contactDescriptionLabel styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                                                                           style.flexShrink = 1.0;
                                                                       }]]]];
    
    return [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                   spacing:SPACE_BETWEEN_ELEMENT
                                            justifyContent:ASStackLayoutJustifyContentStart
                                                alignItems:ASStackLayoutAlignItemsStretch
                                                  children: @[[checkBoxLayout styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.flexShrink    = 1;
    }],
                                                              [avatarLayout styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.flexShrink    = 1;
    }],
                                                              [textLayout styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.flexShrink    = 2;
        style.flexGrow      = 10;
    }]]];
}

- (void)didEnterPreloadState {
    [super didEnterPreloadState];
}

#pragma mark - Subclassing
- (void)setSelect {
    _checkBox.isChecked = !_checkBox.isChecked;
}

- (void)configForModel:(ContactViewEntity *)entity {
    _contactNameLabel.attributedText        = entity.fullName;
    _contactDescriptionLabel.attributedText = entity.phone;
    _checkBox.isChecked                     = entity.isChecked;
    weak_self
    [[ImageManager instance] imageForKey:entity.identifier label:entity.keyName block:^(DataBinding<AvatarObj *> * _Nonnull imageObservable) {
        [imageObservable bindAndFire:^(AvatarObj * imgObj) {
            strong_self
            if (strongSelf && [strongSelf->_contact.identifier isEqualToString:imgObj.identifier]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    strong_self
                    if (strongSelf) {
                        NSString * label = imgObj.isGenerated ? imgObj.label : @"";
                        [strongSelf->_avatar configWithImage:imgObj.image withTitle:label];
                    }
                });
            }
        }];
    }];
}
@end
#endif
