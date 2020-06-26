//
//  PermissionDeniedViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ResponseInformationView.h"

#define DEBUG_MODE          0
#define PERMISSION_MSG      @"Ứng dụng chưa được cấp quyền :("
#define EMPTY_MSG           @"Danh bạ rỗng!"
#define FAILT_MSG           @"Không thể tải danh bạ :("
#define STH_WRONG_MSG       @"Xin lỗi, đã có lỗi xảy ra :("
#define BUTTON_TITLE        @"Mở cài đặt"

#define FAILT_IMG_NAME      @"fail_ico"
#define SUCCESS_IMG_NAME    @"success_ico"

#define ICON_SIZE           100
#define MSG_FONT_SIZE       20
#define BOTTOM_PADDING      72

@interface ResponseInformationView ()
- (void) setupPermissionDeniedView;
- (void) setupEmptyContactView;
- (void) setupFailLoadingContactView;
- (void) setupSomethingWrongView;
- (void) setupView;
@end

@implementation ResponseInformationView {
    UIImageView     *_responseIconView;
    UILabel         *_messageLabel;
    UIButton        *_openSettingBtn;
    UIView          *_contentView;
    ResponseViewType _viewType;
}

- (instancetype)initWithType:(ResponseViewType)viewType {
    if (self = [super init]) {
        _viewType = viewType;
        _responseIconView   = [[UIImageView alloc] init];
        _messageLabel       = [[UILabel alloc] init];
        _openSettingBtn     = [[UIButton alloc] init];
        _contentView        = [[UIView alloc] init];
        
        _messageLabel.numberOfLines     = 0;
        _messageLabel.textColor         = UIColor.blackColor;
        _messageLabel.font              = [UIFont systemFontOfSize:MSG_FONT_SIZE];
        self.backgroundColor            = UIColor.whiteColor;
        
        [_openSettingBtn setTitle:BUTTON_TITLE forState:UIControlStateNormal];
        [_openSettingBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addSubview:_contentView];
    [self addSubview:_openSettingBtn];
    [_contentView addSubview:_responseIconView];
    [_contentView addSubview:_messageLabel];
    
    _contentView.translatesAutoresizingMaskIntoConstraints      = NO;
    _responseIconView.translatesAutoresizingMaskIntoConstraints = NO;
    _messageLabel.translatesAutoresizingMaskIntoConstraints     = NO;
    _openSettingBtn.translatesAutoresizingMaskIntoConstraints   = NO;
    
    [_responseIconView.topAnchor constraintEqualToAnchor:_contentView.topAnchor].active                 = YES;
    [_responseIconView.widthAnchor constraintEqualToConstant:ICON_SIZE].active                          = YES;
    [_responseIconView.heightAnchor constraintEqualToAnchor:_responseIconView.widthAnchor].active       = YES;
    [_responseIconView.centerXAnchor constraintEqualToAnchor:_contentView.centerXAnchor].active         = YES;
    [_responseIconView.leftAnchor constraintGreaterThanOrEqualToAnchor:_contentView.leftAnchor].active  = YES;
    [_responseIconView.rightAnchor constraintLessThanOrEqualToAnchor:_contentView.rightAnchor].active   = YES;
    
    [_messageLabel.topAnchor constraintEqualToAnchor:_responseIconView.bottomAnchor constant:5].active  = YES;
    [_messageLabel.leftAnchor constraintEqualToAnchor:_contentView.leftAnchor].active                   = YES;
    [_messageLabel.rightAnchor constraintEqualToAnchor:_contentView.rightAnchor].active                 = YES;
    [_messageLabel.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor].active               = YES;
    
    [_contentView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_contentView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    [_openSettingBtn.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-BOTTOM_PADDING].active    = YES;
    [_openSettingBtn.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active                           = YES;
    
#if DEBUG_MODE
    _contentView.backgroundColor        = UIColor.greenColor;
    _responseIconView.backgroundColor   = UIColor.redColor;
    _messageLabel.backgroundColor       = UIColor.grayColor;
    _openSettingBtn.backgroundColor     = UIColor.yellowColor;
    self.backgroundColor           = UIColor.brownColor;
#endif
}

- (void)setupView {
    switch (_viewType) {
        case ResponseViewTypePermissionDenied:
            [self setupPermissionDeniedView];
            break;
            
        case ResponseViewTypeEmptyContact:
            [self setupEmptyContactView];
            break;
            
        case ResponseViewTypeFailLoadingContact:
            [self setupFailLoadingContactView];
            break;
            
        case ResponseViewTypeSomethingWrong:
            [self setupSomethingWrongView];
            break;
            
        default:
            break;
    }
    [_openSettingBtn addTarget:self action:@selector(openSettingAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)]];
}

- (void)setupPermissionDeniedView {
    _responseIconView.image = [UIImage imageNamed:FAILT_IMG_NAME];
    _messageLabel.text = PERMISSION_MSG;
    _openSettingBtn.enabled = YES;
}

- (void)setupEmptyContactView {
    _responseIconView.image = [UIImage imageNamed:SUCCESS_IMG_NAME];
    _messageLabel.text = EMPTY_MSG;
    _openSettingBtn.enabled = NO;
    _openSettingBtn.alpha = 0;
}

- (void)setupFailLoadingContactView {
    _responseIconView.image = [UIImage imageNamed:FAILT_IMG_NAME];
    _messageLabel.text = FAILT_MSG;
    _openSettingBtn.enabled = NO;
    _openSettingBtn.alpha = 0;
}

- (void)setupSomethingWrongView {
    _responseIconView.image = [UIImage imageNamed:FAILT_IMG_NAME];
    _messageLabel.text = STH_WRONG_MSG;
    _openSettingBtn.enabled = NO;
    _openSettingBtn.alpha = 0;
}

- (void)openSettingAction:(id)sender {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString] options: @{} completionHandler: nil];
}

- (void) tapGestureAction: (UITapGestureRecognizer *) sender {
    [self.keyboardAppearanceDelegate hideKeyboard];
}

@synthesize keyboardAppearanceDelegate;

@end
