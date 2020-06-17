//
//  HorizontalListItemView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "HorizontalListItemView.h"

@interface HorizontalListItemView()
- (void) customInit;

@end

@implementation HorizontalListItemView

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
    [[NSBundle mainBundle] loadNibNamed:@"HorizontalListItemView" owner:self options:nil];
    [self addSubview:self.mainContentView];
    self.mainContentView.frame = self.bounds;
}

@end
