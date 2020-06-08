//
//  PermissionDeniedViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ResponseInformationViewController.h"

@interface ResponseInformationViewController ()
- (void) setupPermissionDeniedView;
- (void) setupEmptyContactView;
- (void) setupFailLoadingContactView;
- (void) setupSomethingWrongView;
- (void) setupView;
@end

@implementation ResponseInformationViewController

NSString * const _Nonnull PermissionDeniedMsg = @"Ứng dụng chưa được cấp quyền :(";
NSString * const _Nonnull EmptyContactMsg = @"Danh bạ rỗng!";
NSString * const _Nonnull FailLoadingContactMsg = @"Không thể tải danh bạ :(";
NSString * const _Nonnull SomethingWrongMsg = @"Xin lỗi, đã có lỗi xảy ra :(";

+ (ResponseInformationViewController *)instantiateWith:(ResponseViewType)viewType {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ResponseInformationViewController * vc = (ResponseInformationViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"responseInformationViewController"];
    vc->viewType = viewType;
    return vc;
}

- (void)setupView {
    switch (viewType) {
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
}

- (void)setupPermissionDeniedView {
    self.responseIconView.image = [UIImage imageNamed:@"fail_ico"];
    self.messageLabel.text = PermissionDeniedMsg;
    self.openSettingBtn.enabled = YES;
}

- (void)setupEmptyContactView {
    self.responseIconView.image = [UIImage imageNamed:@"success_ico"];
    self.messageLabel.text = EmptyContactMsg;
    self.openSettingBtn.enabled = NO;
    self.openSettingBtn.alpha = 0;
}

- (void)setupFailLoadingContactView {
    self.responseIconView.image = [UIImage imageNamed:@"fail_ico"];
    self.messageLabel.text = FailLoadingContactMsg;
    self.openSettingBtn.enabled = NO;
    self.openSettingBtn.alpha = 0;
}

- (void)setupSomethingWrongView {
    self.responseIconView.image = [UIImage imageNamed:@"fail_ico"];
    self.messageLabel.text = SomethingWrongMsg;
    self.openSettingBtn.enabled = NO;
    self.openSettingBtn.alpha = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)]];
}
- (IBAction)openSettingAction:(id)sender {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString] options: @{} completionHandler: nil];
}

- (void) tapGestureAction: (UITapGestureRecognizer *) sender {
    [self.keyboardAppearanceDelegate hideKeyboard];
}

@synthesize keyboardAppearanceDelegate;

@end
