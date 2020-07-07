//
//  ContactCollectionCell.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactCollectionCell.h"
#import "ContactViewEntity.h"
#import "ImageManager.h"
#import "ContactDefine.h"

#define CLOSE_BTN_WIDTH     20

@interface ContactCollectionCell() {
    NSString                *_currentIdentifier;
}
- (void)initElements;
@end

@implementation ContactCollectionCell

@synthesize delegate;

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
    _avatar = [[ContactAvatarView alloc] initWithFrame:self.frame];
    _button = [[UIButton alloc] init];
    
    [_button setBackgroundImage:[UIImage imageNamed:@"close_ico"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addSubview:_avatar];
    [self addSubview:_button];
    
    _avatar.translatesAutoresizingMaskIntoConstraints = NO;
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_avatar.topAnchor constraintEqualToAnchor:self.topAnchor].active       = YES;
    [_avatar.leftAnchor constraintEqualToAnchor:self.leftAnchor].active     = YES;
    [_avatar.rightAnchor constraintEqualToAnchor:self.rightAnchor].active   = YES;
    [_avatar.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [_button.topAnchor constraintEqualToAnchor:self.topAnchor].active       = YES;
    [_button.rightAnchor constraintEqualToAnchor:self.rightAnchor].active   = YES;
    [_button.widthAnchor constraintEqualToConstant:CLOSE_BTN_WIDTH].active  = YES;
    [_button.heightAnchor constraintEqualToAnchor:_button.widthAnchor].active   = YES;
}

- (void)closeAction:(id)sender {
    [self.delegate removeCell:self->_currentIdentifier];
}

- (void)binding:(NSString *)identifier label:(NSString *)label {
    _currentIdentifier  = identifier;
    weak_self
    [[ImageManager instance] imageForKey:identifier label:label block:^(DataBinding<AvatarObj *> * _Nonnull imageObservable) {
        [imageObservable bindAndFire:^(AvatarObj * imgObj) {
            strong_self
            if (strongSelf && [strongSelf->_currentIdentifier isEqualToString:imgObj.identifier]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    strong_self
                    if (strongSelf) {
                        NSString * label = imgObj.isGenerated ? imgObj.label : @"";
                        [strongSelf->_avatar configWithImage:imgObj.image withTitle:label];
                    }
                });
            }
        }];
    }];
}

@end
