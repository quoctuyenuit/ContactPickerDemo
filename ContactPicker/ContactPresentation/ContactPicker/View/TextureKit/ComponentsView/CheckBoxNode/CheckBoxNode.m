//
//  CheckBoxNode.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "CheckBoxNode.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@implementation CheckBoxNode

- (BOOL)isChecked {
    return self->_isChecked;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isChecked                      = NO;
        self.automaticallyManagesSubnodes   = YES;
        [self addTarget:self action:@selector(checkAction:) forControlEvents:ASControlNodeEventTouchUpInside];
    }
    return self;
}

- (void)setIsChecked:(BOOL)isChecked {
    self->_isChecked = isChecked;
    UIImage * backgroundImage = isChecked ? [UIImage imageNamed:@"checked_img"] : [UIImage imageNamed:@"unchecked_img"];
    [self setBackgroundImage: backgroundImage forState:UIControlStateNormal];
}

- (void)checkAction:(id) sender {
    self.isChecked = !self->_isChecked;
    [self.delegate check:self->_isChecked];
}
@end
