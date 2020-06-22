//
//  TabbarOnTopItemView.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "TabbarOnTopItemView.h"

#define DEBUG_MODE              0
#define NORMAL_COLOR            UIColor.lightGrayColor;
#define DEFAULT_HIGHLIGH_COLOR  UIColor.blueColor;
#define DEFAULT_TEXT_FONT_SIZE  17
#define IMAGE_WIDTH             30

@interface TabbarOnTopItemView()
- (void)highLighItem:(BOOL) isHighLight;
- (void)setupViews;
@end

@implementation TabbarOnTopItemView {
    UIView              * _underLine;
    BOOL                  _isHighLight;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    self = [super init];
    if (self) {
        _label       = [[UILabel alloc] init];
        _underLine   = [[UIView alloc] init];
        
        _label.text             = title;
        _label.font             = [UIFont systemFontOfSize:DEFAULT_TEXT_FONT_SIZE];
        _label.textAlignment    = NSTextAlignmentCenter;
        
        _itemColor   = DEFAULT_HIGHLIGH_COLOR;
        _imageView   = image ? [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]] : nil;
        
        _isHighLight = NO;
        
        [self highLighItem:NO];
        [self addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)]];
        
#if DEBUG_MODE
        _imageView.backgroundColor          = UIColor.yellowColor;
        _label.backgroundColor              = UIColor.redColor;
        _underLine.backgroundColor          = UIColor.greenColor;
#endif
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupViews];
}

- (void)setIsHighLight:(BOOL)isHighLight {
    _isHighLight = isHighLight;
    [self highLighItem:_isHighLight];
}

- (BOOL)isHighLight {
    return _isHighLight;
}

- (void)highLighItem:(BOOL)isHighLight {
    if (_imageView) {
        _imageView.tintColor    = isHighLight ? _itemColor : NORMAL_COLOR;
    }
    _label.textColor            = isHighLight ? _itemColor : NORMAL_COLOR;
    _underLine.backgroundColor  = isHighLight ? _itemColor : NORMAL_COLOR;
}

- (void)setupViews {
    [self addSubview:_label];
    [self addSubview:_underLine];
    
    
    _label.translatesAutoresizingMaskIntoConstraints        = NO;
    _underLine.translatesAutoresizingMaskIntoConstraints    = NO;
    
    NSLayoutYAxisAnchor * topAnchor = self.topAnchor;
    
    if (_imageView) {
        [self addSubview:_imageView];
        _imageView.translatesAutoresizingMaskIntoConstraints    = NO;
        
        [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor].active                = YES;
        [_imageView.heightAnchor constraintEqualToAnchor:_imageView.widthAnchor].active    = YES;
        [_imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active        = YES;
        
        NSLayoutConstraint * imageHeightConstraint = [_imageView.widthAnchor constraintEqualToConstant:IMAGE_WIDTH];
        imageHeightConstraint.priority  = UILayoutPriorityDefaultLow;
        imageHeightConstraint.active    = YES;
        topAnchor = _imageView.bottomAnchor;
    }
    
    [_label.topAnchor constraintEqualToAnchor:topAnchor].active             = YES;
    [_label.leftAnchor constraintEqualToAnchor:self.leftAnchor].active      = YES;
    [_label.rightAnchor constraintEqualToAnchor:self.rightAnchor].active    = YES;
    [_label.heightAnchor constraintEqualToConstant:25].active               = YES;
    
    [_underLine.topAnchor constraintEqualToAnchor:_label.bottomAnchor].active      = YES;
    [_underLine.leftAnchor constraintEqualToAnchor:self.leftAnchor].active      = YES;
    [_underLine.rightAnchor constraintEqualToAnchor:self.rightAnchor].active    = YES;
    [_underLine.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active  = YES;
    [_underLine.heightAnchor constraintEqualToConstant:1].active              = YES;
}

- (void)tapGestureAction:(id) sender {
    [self.delegate didTapOnItem:self state:_isHighLight];
}

@end
