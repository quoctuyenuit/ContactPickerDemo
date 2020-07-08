//
//  ContactTableViewCell.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/4/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "ContactDefine.h"
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "ImageManager.h"

#define DEBUG_MODE          0
#define CHECK_MEM_LEAKS     0
#define CHECKBOX_SIZE       25
#define AVATAR_SIZE         55
#define LEFT_PADDING        16
#define RIGHT_PADDING       16
#define SPACE_BETWEEN_ELE   16

@interface ContactTableViewCell() {
    ContactAvatarView       *_avatar;
    UILabel                 *_contactNameLabel;
    UILabel                 *_contactDescriptionLabel;
    CheckBoxButtonView      *_checkBox;
    UIView                  *_textBoundView;
    NSString                *_currentIdentifier;
    
    
    void (^_block)(void);
}
- (void)initElements;
@end

@implementation ContactTableViewCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initElements];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initElements];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initElements];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:_checkBox];
    [self addSubview:_avatar];
    [self addSubview:_textBoundView];
    [_textBoundView addSubview:_contactNameLabel];
    [_textBoundView addSubview:_contactDescriptionLabel];
    
    _checkBox.translatesAutoresizingMaskIntoConstraints                 = NO;
    _avatar.translatesAutoresizingMaskIntoConstraints                   = NO;
    _textBoundView.translatesAutoresizingMaskIntoConstraints            = NO;
    _contactNameLabel.translatesAutoresizingMaskIntoConstraints         = NO;
    _contactDescriptionLabel.translatesAutoresizingMaskIntoConstraints  = NO;
    
    [_checkBox.widthAnchor constraintEqualToConstant:CHECKBOX_SIZE].active          = YES;
    [_checkBox.heightAnchor constraintEqualToAnchor:_checkBox.widthAnchor].active   = YES;
    [_checkBox.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active     = YES;
    [_checkBox.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:LEFT_PADDING].active   = YES;
    
    [_avatar.leftAnchor constraintEqualToAnchor:_checkBox.rightAnchor constant:SPACE_BETWEEN_ELE].active    = YES;
    [_avatar.heightAnchor constraintEqualToAnchor:_avatar.widthAnchor].active                               = YES;
    [_avatar.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active                               = YES;
    NSLayoutConstraint *avatarWidthConstraint = [_avatar.widthAnchor constraintEqualToConstant:AVATAR_SIZE];
    NSLayoutConstraint *avatarTopConstraint = [_avatar.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:8];
    
    
    [_contactNameLabel.topAnchor constraintEqualToAnchor:_textBoundView.topAnchor].active       = YES;
    [_contactNameLabel.leftAnchor constraintEqualToAnchor:_textBoundView.leftAnchor].active     = YES;
    [_contactNameLabel.rightAnchor constraintEqualToAnchor:_textBoundView.rightAnchor].active   = YES;
    
    [_contactDescriptionLabel.topAnchor constraintEqualToAnchor:_contactNameLabel.bottomAnchor constant:5].active  = YES;
    [_contactDescriptionLabel.leftAnchor constraintEqualToAnchor:_textBoundView.leftAnchor].active                  = YES;
    [_contactDescriptionLabel.rightAnchor constraintEqualToAnchor:_textBoundView.rightAnchor].active                = YES;
    [_contactDescriptionLabel.bottomAnchor constraintEqualToAnchor:_textBoundView.bottomAnchor].active              = YES;
    
    [_textBoundView.leftAnchor constraintEqualToAnchor:_avatar.rightAnchor constant:SPACE_BETWEEN_ELE].active  = YES;
    [_textBoundView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-RIGHT_PADDING].active                    = YES;
    [_textBoundView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active                            = YES;
    
    avatarTopConstraint.priority    = UILayoutPriorityRequired;
    avatarWidthConstraint.priority  = UILayoutPriorityDefaultHigh;
    
    avatarTopConstraint.active      = YES;
    avatarWidthConstraint.active    = YES;
    
#if DEBUG_MODE
    self.backgroundColor                        = UIColor.blueColor;
    _checkBox.backgroundColor                   = UIColor.blackColor;
    _avatar.backgroundColor                     = UIColor.redColor;
    _textBoundView.backgroundColor              = UIColor.greenColor;
    _contactNameLabel.backgroundColor           = UIColor.grayColor;
    _contactDescriptionLabel.backgroundColor    = UIColor.brownColor;
#endif
}

- (void)initElements {
    _checkBox                   = [[CheckBoxButtonView alloc] initWithFrame:CGRectZero];
    _avatar                     = [[ContactAvatarView alloc] initWithFrame:CGRectZero];
    _textBoundView              = [[UIView alloc] init];
    _contactNameLabel           = [[UILabel alloc] init];
    _contactDescriptionLabel    = [[UILabel alloc] init];
    
    [_checkBox setUserInteractionEnabled:NO];
    [self setupViews];
}

- (void)updateCellWithContact:(ContactViewEntity *)entity {
    _currentIdentifier                      = entity.identifier;
    _contactNameLabel.attributedText        = entity.fullName;
    _contactDescriptionLabel.attributedText = entity.phone;
    _checkBox.isChecked                     = entity.isChecked;

    weak_self
    [[ImageManager instance] imageForKey:entity.identifier label:entity.keyName block:^(DataBinding<AvatarObj *> * _Nonnull imageObservable) {
        [imageObservable bindAndFire:^(AvatarObj * imgObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strong_self
                if (strongSelf && [strongSelf->_currentIdentifier isEqualToString:imgObj.identifier]) {
                    NSString * label = imgObj.isGenerated ? imgObj.label : @"";
                    [strongSelf->_avatar configWithImage:imgObj.image withTitle:label];
                }
            });
        }];
    }];
}

- (void)configCheckBox:(BOOL)isChecked {
    _checkBox.isChecked = isChecked;
}

- (void)setSelect {
    _checkBox.isChecked = !_checkBox.isChecked;
}
@end
