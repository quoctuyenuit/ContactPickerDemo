//
//  ContactTableHeaderComponentView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/25/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableHeaderComponentView.h"

#define TITLE_FONT_SIZE         17

@interface ContactTableHeaderComponentView ()
- (void)initElements;

@end
@implementation ContactTableHeaderComponentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initElements];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initElements];
    }
    return self;
}

- (void)initElements {
    _title                  = [[UILabel alloc] init];
    _title.font             = [UIFont systemFontOfSize:TITLE_FONT_SIZE weight:UIFontWeightSemibold];
    _title.textColor        = [UIColor colorWithRed:0.14 green:0.14 blue:0.14 alpha:1];
    self.backgroundColor    = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addSubview:_title];
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    [_title.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:15].active = YES;
    [_title.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active       = YES;
}

@end
