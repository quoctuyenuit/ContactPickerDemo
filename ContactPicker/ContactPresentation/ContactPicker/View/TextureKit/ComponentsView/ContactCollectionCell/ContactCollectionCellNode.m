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
        
//        [self binding:contact];
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
    weak_self
    [[ImageManager instance] imageForKey:_currentContact.identifier label:_currentContact.keyName block:^(DataBinding<AvatarObj *> * _Nonnull imageObservable) {
        [imageObservable bindAndFire:^(AvatarObj * imgObj) {
            strong_self
            if (strongSelf && [strongSelf->_currentContact.identifier isEqualToString:imgObj.identifier]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    strong_self
                    if (strongSelf) {
                        NSString * label = imgObj.isGenerated ? imgObj.label : @"";
                        [strongSelf->_avatarNode configWithImage:imgObj.image withTitle:label];
                    }
                });
            }
        }];
    }];
}

- (void)binding:(nonnull ContactViewEntity *)entity {
   
}

- (void)clearAction:(id) sender {
    [self.delegate removeCell:_currentContact];
}
@end
#endif
