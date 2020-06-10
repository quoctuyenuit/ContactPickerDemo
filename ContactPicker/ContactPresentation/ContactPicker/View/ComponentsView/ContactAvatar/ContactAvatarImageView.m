//
//  ContactAvatarImageView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/5/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactAvatarImageView.h"

@interface ContactAvatarImageView()
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
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setupView];
}

- (void)setupView {
    self.mainContentView.layer.cornerRadius = self.imageView.bounds.size.width / 2;
    self.mainContentView.layer.borderWidth = 1;
    self.mainContentView.layer.borderColor = UIColor.grayColor.CGColor;
}

- (void)showImage {
    self.imageView.alpha = 1;
    self.label.alpha = 0;
}

- (void)showLabel {
    self.imageView.alpha = 0;
    self.label.alpha = 1;
}

- (void)configImage:(UIImage * _Nullable)image forLabel:(NSString *)label {
    self.imageView.image = image;
    self.label.text = label;
    
    self.imageView.alpha = (image == nil) ? 0 : 1;
    self.label.alpha = ([label isEqualToString: @""]) ? 0 : 1;
}
@end
