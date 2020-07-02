//
//  CheckBoxButtonView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "CheckBoxButtonView.h"

@interface CheckBoxButtonView()
-(void) customInit;
@end

@implementation CheckBoxButtonView

-(BOOL) isChecked {
    return self->_isChecked;
}

- (void)setIsChecked:(BOOL)isChecked {
    self->_isChecked = isChecked;
    UIImage * backgroundImage = isChecked ? [UIImage imageNamed:@"checked_img"] : [UIImage imageNamed:@"unchecked_img"];
    [self setBackgroundImage: backgroundImage forState:UIControlStateNormal];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    self.isChecked = NO;
    [self addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)checkAction:(id)sender {
    self.isChecked = !self.isChecked;
    [self.delegate check: self.isChecked];
}

@end
