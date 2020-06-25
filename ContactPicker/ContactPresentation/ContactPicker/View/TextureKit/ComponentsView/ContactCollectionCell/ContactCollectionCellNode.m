//
//  ContactCollectionCellNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactCollectionCellNode.h"
#import "ContactAvatarNode.h"

#define DEBUG_MODE          0
#define CLEAR_BTN_SIZE      CGSizeMake(20,20)

@implementation ContactCollectionCellNode {
    ContactAvatarNode       * _avatarNode;
    ASButtonNode            * _clearBtnNode;
    ContactViewEntity       * _currentContact;
}

@synthesize delegate;

- (instancetype)initWithContact:(ContactViewEntity *)contact {
    self = [super init];
    if (self) {
        _avatarNode             = [[ContactAvatarNode alloc] init];
        _clearBtnNode           = [[ASButtonNode alloc] init];
        _currentContact         = contact;
        
        UIImage * btnImage = [UIImage imageNamed:@"close_ico"];
        [_clearBtnNode setBackgroundImage:btnImage forState:UIControlStateNormal];
        
        [_clearBtnNode addTarget:self action:@selector(clearAction:) forControlEvents:ASControlNodeEventTouchUpInside];
        
        self.automaticallyManagesSubnodes = YES;
        
        [self configWithEntity:contact];
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

- (void)configWithEntity:(nonnull ContactViewEntity *)entity {
    NSString * firstString = entity.givenName.length > 0 ? [entity.givenName substringToIndex:1] : @"";
    NSString * secondString = entity.familyName.length > 0 ? [entity.familyName substringToIndex:1] : @"";
    NSString * keyName = [NSString stringWithFormat:@"%@%@", firstString, secondString];
    
    if (entity.avatar) {
        [_avatarNode configWithImage:entity.avatar forLabel:@"" withGradientColor:nil];
    } else {
        [_avatarNode configWithImage:nil forLabel:keyName withGradientColor:entity.backgroundColor];
    }
    __weak typeof(self) weakSelf = self;
    entity.waitImageSelectedToExcuteQueue = ^(UIImage * image, NSString * identifier) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([identifier isEqualToString:strongSelf->_currentContact.identifier]) {
                [strongSelf->_avatarNode configWithImage:image forLabel:@"" withGradientColor:nil];
            }
        }
    };
}

- (void)clearAction:(id) sender {
    [self.delegate removeCell:_currentContact];
}
@end
