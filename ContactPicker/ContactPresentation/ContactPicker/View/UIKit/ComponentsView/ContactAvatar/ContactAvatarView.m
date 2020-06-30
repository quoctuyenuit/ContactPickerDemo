//
//  ContactAvatarView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/23/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactAvatarView.h"

#define DEBUG_MODE      0
#define FONT_SIZE       20
#import "Utilities.h"

@interface ContactAvatarView ()
- (void) initElement;
- (void) layoutViews;
@end

@implementation ContactAvatarView {
    UIView                  * _mainBoundView;
    UIImageView             * _imageView;
    UILabel                 * _label;
    CAGradientLayer         * _gradientBackground;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initElement];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initElement];
    }
    return self;
}

- (void)initElement {
    _mainBoundView      = [[UIView alloc] init];
    _imageView          = [[UIImageView alloc] init];
    _label              = [[UILabel alloc] init];
    _gradientBackground = [CAGradientLayer layer];
    
    _label.font             = [UIFont systemFontOfSize:FONT_SIZE];
    _label.textColor        = UIColor.whiteColor;
    _label.textAlignment    = NSTextAlignmentCenter;
    
    [_imageView setContentMode: UIViewContentModeScaleAspectFill];
    [_imageView.layer setMasksToBounds:YES];
    
    _mainBoundView.backgroundColor  = UIColor.clearColor;
    self.backgroundColor            = UIColor.clearColor;
}

#pragma mark - Life circle methods
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutViews];
    
    _gradientBackground.frame           = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _gradientBackground.cornerRadius    = _gradientBackground.frame.size.width / 2;
    _imageView.layer.cornerRadius       = self.frame.size.width / 2;
    self.layer.cornerRadius             = self.frame.size.width / 2;
}

#pragma mark - Helper methods
- (void)layoutViews {
    [self addSubview:_mainBoundView];
    [_mainBoundView addSubview:_imageView];
    [_mainBoundView addSubview:_label];
    [_mainBoundView.layer insertSublayer:_gradientBackground atIndex:0];
    
    _mainBoundView.translatesAutoresizingMaskIntoConstraints    = NO;
    _imageView.translatesAutoresizingMaskIntoConstraints        = NO;
    _label.translatesAutoresizingMaskIntoConstraints            = NO;
    
    [_mainBoundView.topAnchor constraintEqualToAnchor:self.topAnchor].active        = YES;
    [_mainBoundView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active      = YES;
    [_mainBoundView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active    = YES;
    [_mainBoundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active  = YES;
    
    [_imageView.topAnchor constraintEqualToAnchor:_mainBoundView.topAnchor].active        = YES;
    [_imageView.leftAnchor constraintEqualToAnchor:_mainBoundView.leftAnchor].active      = YES;
    [_imageView.rightAnchor constraintEqualToAnchor:_mainBoundView.rightAnchor].active    = YES;
    [_imageView.bottomAnchor constraintEqualToAnchor:_mainBoundView.bottomAnchor].active  = YES;
    [_imageView.widthAnchor constraintEqualToAnchor:_mainBoundView.widthAnchor].active    = YES;
    [_imageView.heightAnchor constraintEqualToAnchor:_mainBoundView.heightAnchor].active  = YES;
    
    
    [_label.topAnchor constraintEqualToAnchor:_mainBoundView.topAnchor].active        = YES;
    [_label.leftAnchor constraintEqualToAnchor:_mainBoundView.leftAnchor].active      = YES;
    [_label.rightAnchor constraintEqualToAnchor:_mainBoundView.rightAnchor].active    = YES;
    [_label.bottomAnchor constraintEqualToAnchor:_mainBoundView.bottomAnchor].active  = YES;
    
#if DEBUG_MODE
    _mainBoundView.backgroundColor      = UIColor.greenColor;
    _label.backgroundColor              = UIColor.redColor;
    _imageView.backgroundColor          = UIColor.yellowColor;
#endif
}

#pragma mark - Public methods
- (void)configWithImage:(UIImage *)image withTitle:(NSString *)title withBackground:(NSArray *)backgroundColor {
    _imageView.image            = image;
    _label.text                 = title;
    _gradientBackground.colors  = backgroundColor;
    
    _imageView.alpha    = image ? 1 : 0;
    _label.alpha        = [title isEqualToString:@""] ? 0 : 1;
}

@end
