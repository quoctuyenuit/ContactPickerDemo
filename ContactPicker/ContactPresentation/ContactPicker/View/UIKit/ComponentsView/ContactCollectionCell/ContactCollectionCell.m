//
//  ContactCollectionCell.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactCollectionCell.h"
#import "ContactViewEntity.h"

#define CLOSE_BTN_WIDTH     20

@interface ContactCollectionCell() {
    ContactViewEntity * _currentContact;
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
    [self.delegate removeCell:self->_currentContact];
}

- (void)configWithEntity:(ContactViewEntity *)entity {
    self->_currentContact = entity;
    NSString * firstString = entity.givenName.length > 0 ? [entity.givenName substringToIndex:1] : @"";
    NSString * secondString = entity.familyName.length > 0 ? [entity.familyName substringToIndex:1] : @"";
    NSString * keyName = [NSString stringWithFormat:@"%@%@", firstString, secondString];
    
    if (entity.avatar) {
        [_avatar configWithImage:entity.avatar withTitle:@"" withBackground:nil];
    } else {
        [_avatar configWithImage:nil withTitle:keyName withBackground:entity.backgroundColor];
    }
    
    __weak typeof(self) weakSelf = self;
    entity.waitImageSelectedToExcuteQueue = ^(UIImage* image, NSString* identifier){
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && identifier == entity.identifier) {
                [strongSelf->_avatar configWithImage:image withTitle:@"" withBackground:nil];
            }
        });
    };
}

@end
