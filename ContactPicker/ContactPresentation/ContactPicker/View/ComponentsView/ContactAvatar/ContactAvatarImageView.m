//
//  ContactAvatarImageView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/5/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactAvatarImageView.h"

@interface ContactAvatarImageView() {
    CAGradientLayer *gradient;
}
- (void) customeInit;
- (void) setupView;
@end

@implementation ContactAvatarImageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customeInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customeInit];
    }
    return self;
}

- (void)customeInit {
    [[NSBundle mainBundle] loadNibNamed:@"ContactAvatarImageView" owner:self options:nil];
    [self addSubview:self.mainContentView];
    self.mainContentView.frame = self.bounds;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = UIColor.clearColor;
    self->gradient = [CAGradientLayer layer];
    gradient.frame = self.mainContentView.bounds;
    gradient.cornerRadius = gradient.bounds.size.width / 2;
    [self.mainContentView.layer insertSublayer:gradient atIndex:1];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setupView];
}

- (void)setupView {
    self.mainContentView.layer.cornerRadius = self.imageView.bounds.size.width / 2;
    self.mainContentView.layer.borderWidth = 1;
    self.mainContentView.layer.borderColor = UIColor.grayColor.CGColor;
    
    self.imageView.layer.cornerRadius = self.imageView.bounds.size.width / 2;
    self.imageView.layer.borderWidth = 1;
    self.imageView.layer.borderColor = UIColor.grayColor.CGColor;
}

- (void)showImage {
    self.imageView.alpha = 1;
    self.label.alpha = 0;
}

- (void)showLabel {
    self.imageView.alpha = 0;
    self.label.alpha = 1;
}

- (void)configImage:(UIImage * _Nullable)image forLabel:(NSString *)label withColor:(nonnull UIColor *)color {
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.label.text = [label uppercaseString];
    self.imageView.alpha = (image == nil) ? 0 : 1;
    self.label.alpha = ([label isEqualToString: @""]) ? 0 : 1;
    gradient.colors = @[(id)[UIColor lightGrayColor].CGColor, (id)color.CGColor];
}
@end
