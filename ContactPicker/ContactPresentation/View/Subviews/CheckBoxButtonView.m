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
-(void) tappedButton: (UIButton*) sender;
@end

@implementation CheckBoxButtonView

-(BOOL) isChecked {
    return self->_checked;
}

- (void)setChecked:(BOOL)checked {
    self->_checked = checked;
    if (checked) {
        [self.button setBackgroundImage:[UIImage imageNamed:@"checked_img"] forState:UIControlStateNormal];
    } else {
        [self.button setBackgroundImage:[UIImage imageNamed:@"unchecked_img"] forState:UIControlStateNormal];
    }
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
    self->_checked = NO;
    [[NSBundle mainBundle] loadNibNamed:@"CheckBoxButtonView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
    [self.button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tappedButton:(UIButton *)sender {
    self.checked = !self.checked;
}
@end
