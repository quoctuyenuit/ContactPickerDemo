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
#import "ContactGlobalConfigure.h"

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

@interface ContactTableCellNode ()

@property(nonatomic) ContactViewEntity   * contact;
@property(nonatomic) CheckBoxNode        * checkBox;
@property(nonatomic) ContactAvatarNode   * avatar;
@property(nonatomic) ASTextNode          * contactNameLabel;
@property(nonatomic) ASTextNode          * contactDescriptionLabel;

@end

@implementation ContactTableCellNode

- (instancetype)initWithContact:(ContactViewEntity *)contact {
    self = [super init];
    
    if (self) {
        _contact                            = contact;
        _avatar                             = [[ContactAvatarNode alloc] init];
        _contactNameLabel                   = [[ASTextNode alloc] init];
        _contactDescriptionLabel            = [[ASTextNode alloc] init];
        _checkBox                           = [[CheckBoxNode alloc] init];
        
        _avatar.style.preferredSize         = [ContactGlobalConfigure globalConfig].avatarSize;
        _checkBox.style.preferredSize       = CGSizeMake(CHECK_BOX_HEIGHT, CHECK_BOX_HEIGHT);
        _checkBox.userInteractionEnabled    = NO;
        self.automaticallyManagesSubnodes   = YES;
        
        ContactGlobalConfigure *config      = [ContactGlobalConfigure globalConfig];
        _avatar.backgroundColor             = config.avatarBackgroundColor;
        self.backgroundColor                = config.backgroundColor;
        
        [self updateCellWithContact:_contact];
#if DEBUG_MODE
        _avatar.backgroundColor                   = UIColor.redColor;
        _contactNameLabel.backgroundColor         = UIColor.grayColor;
        _contactDescriptionLabel.backgroundColor  = UIColor.blueColor;
        _checkBox.backgroundColor                 = UIColor.lightGrayColor;
        self.backgroundColor                      = UIColor.greenColor;
#endif
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    //------------------------------------------------------------
    //    CheckBox layout
    //------------------------------------------------------------
    ASLayoutSpec * checkBoxLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:InsetForCheckBox
                                                                           child:
                                     [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringY
                                                                                sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                                                        child:_checkBox]];
    //------------------------------------------------------------
    //    Avatar layout
    //------------------------------------------------------------
    ASLayoutSpec * avatarLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:InsetForAvatar
                                                                         child: [_avatar styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = [ContactGlobalConfigure globalConfig].avatarSize;
    }]];
    
    //------------------------------------------------------------
    //    Text layout
    //------------------------------------------------------------
    ASLayoutSpec *textCenterLayout = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                             spacing:5
                                                                      justifyContent:ASStackLayoutJustifyContentCenter
                                                                          alignItems:ASStackLayoutAlignItemsStart
                                                                            children:
                                      [_contact.phone.string isEqualToString:@""] ?
                                      @[[_contactNameLabel styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.flexShrink = 1.0;
    }],
                                        [_contactDescriptionLabel styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.flexShrink = 1.0;
    }]] :
                                      @[[_contactNameLabel styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.flexShrink = 1.0;
    }]]];
    
    ASLayoutSpec * textLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:InsetForText
                                                                       child:textCenterLayout];
    
    //------------------------------------------------------------
    //    Combine
    //------------------------------------------------------------
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

#pragma mark - Subclassing
- (void)setSelect {
    _checkBox.isChecked = !_checkBox.isChecked;
}

- (void)updateCellWithContact:(ContactViewEntity *)entity {
    if (entity) {
        _contactNameLabel.attributedText        = entity.fullName;
        _contactDescriptionLabel.attributedText = entity.phone;
        _checkBox.isChecked                     = entity.isChecked;
        
        weak_self
        [[ImageManager instance] imageForKey:entity.identifier  label:entity.keyName block:^(AvatarObj * _Nonnull image, NSString * _Nonnull identifier) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strong_self
                if (strongSelf && [strongSelf->_contact.identifier isEqualToString:identifier]) {
                    NSString * label = image.isGenerated ? image.label : @"";
                    [strongSelf->_avatar configWithImage:image.image withTitle:label];
                }
            });
        }];
    }
}
@end
#endif
