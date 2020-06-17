//
//  ContactCollectionCellNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/17/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactCollectionCellNode.h"
#import "ContactAvatarNode.h"

#define DEBUG_MODE          1
#define CLEAR_BTN_SIZE      CGSizeMake(20,20)

@implementation ContactCollectionCellNode {
    ContactAvatarNode       * _avatarNode;
    ASButtonNode            * _clearBtnNode;
}

@synthesize delegate;

- (instancetype)initWithEntity:(ContactViewEntity *)entity {
    self = [super init];
    if (self) {
        _avatarNode             = [[ContactAvatarNode alloc] init];
        _clearBtnNode           = [[ASButtonNode alloc] init];
        
        UIImage * btnImage = [[UIImage imageNamed:@"multiply.circle.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_clearBtnNode setBackgroundImage:btnImage forState:UIControlStateNormal];
        _clearBtnNode.tintColor = [UIColor.grayColor colorWithAlphaComponent:0.85];
        
        self.automaticallyManagesSubnodes = YES;
#if DEBUG_MODE
        _avatarNode.backgroundColor         = UIColor.greenColor;
        _clearBtnNode.backgroundColor       = UIColor.redColor;
#endif
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    __weak typeof(self) weakSelf = self;
    return [ASOverlayLayoutSpec overlayLayoutSpecWithChild:[_avatarNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = weakSelf.calculatedSize;
    }] overlay:[_clearBtnNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
        style.preferredSize = CLEAR_BTN_SIZE;
    }]];
}

- (void)configWithEntity:(nonnull ContactViewEntity *)entity {
    
}

@end
