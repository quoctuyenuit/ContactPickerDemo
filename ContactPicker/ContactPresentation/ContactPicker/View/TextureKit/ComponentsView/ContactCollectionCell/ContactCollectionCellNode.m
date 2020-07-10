//
//  ContactCollectionCellNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import "ContactCollectionCellNode.h"
#import "ContactAvatarNode.h"
#import "ImageManager.h"

#define DEBUG_MODE          0
#define CLEAR_BTN_SIZE      CGSizeMake(20,20)

@implementation ContactCollectionCellNode {
    ContactAvatarNode       * _avatarNode;
    ASButtonNode            * _clearBtnNode;
    NSString                * _currentIdentifier;
    NSString                * _currentKeyName;
}

@synthesize delegate;

- (instancetype)initWithContact:(ContactViewEntity *)contact {
    self = [super init];
    if (self) {
        _avatarNode             = [[ContactAvatarNode alloc] init];
        _clearBtnNode           = [[ASButtonNode alloc] init];
        _currentIdentifier      = contact.identifier;
        _currentKeyName         = contact.keyName;
        
        UIImage * btnImage = [UIImage imageNamed:@"close_ico"];
        [_clearBtnNode setBackgroundImage:btnImage forState:UIControlStateNormal];
        
        [_clearBtnNode addTarget:self action:@selector(clearAction:) forControlEvents:ASControlNodeEventTouchUpInside];
        
        self.automaticallyManagesSubnodes = YES;
        
        [self binding:_currentIdentifier label:_currentKeyName];
#if DEBUG_MODE
        _avatarNode.backgroundColor         = UIColor.greenColor;
        _clearBtnNode.backgroundColor       = UIColor.redColor;
#endif
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    __weak typeof(self) weakSelf = self;
    
    ASLayoutSpec * buttonLayout = [ASRelativeLayoutSpec relativePositionLayoutSpecWithHorizontalPosition:ASRelativeLayoutSpecPositionEnd
                                                                                        verticalPosition:ASRelativeLayoutSpecPositionStart
                                                                                            sizingOption:ASRelativeLayoutSpecSizingOptionDefault
                                                                                                   child: [_clearBtnNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = CLEAR_BTN_SIZE;
    }]];
    
    
    return [ASOverlayLayoutSpec overlayLayoutSpecWithChild:[_avatarNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = weakSelf.calculatedSize;
    }] overlay:buttonLayout];
}

- (void)didEnterDisplayState {
    [super didEnterDisplayState];
}

- (void)binding:(NSString *)identifier label:(NSString *)label {
    weak_self
    [[ImageManager instance] imageForKey:identifier block:^(AvatarObj * _Nonnull image, NSString * _Nonnull identifier) {
        dispatch_async(dispatch_get_main_queue(), ^{
            strong_self
            if (strongSelf && [strongSelf->_currentIdentifier isEqualToString:identifier]) {
                NSString * inlabel = image.isGenerated ? label : @"";
                [strongSelf->_avatarNode configWithImage:image.image withTitle:inlabel];
            }
        });
    }];
}

- (void)clearAction:(id) sender {
    [self.delegate removeCell:_currentIdentifier];
}
@end
#endif
