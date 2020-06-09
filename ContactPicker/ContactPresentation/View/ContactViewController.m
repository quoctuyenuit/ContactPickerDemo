//
//  ContactViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactTableViewController.h"
#import "ContactViewModel.h"
#import "ResponseInformationViewController.h"
#import "KeyboardAppearanceDelegate.h"
#import "Logging.h"

@interface ContactViewController () {
    UIViewController<KeyboardAppearanceProtocol> * contentViewController;
    ContactViewModel * viewModel;
}
extern NSString * const loadingMsg;

- (void) setupViews;
- (void) setupEvents;
- (UIViewController<KeyboardAppearanceProtocol> *) loadContactTableViewController;
- (UIViewController<KeyboardAppearanceProtocol> *) loadFailLoadingContactViewController;
- (UIViewController<KeyboardAppearanceProtocol> *) loadEmptyViewController;
- (UIAlertController *) createLoadingView: (NSString *) msg;
@end

@implementation ContactViewController

NSString * const loadingMsg = @"Đang tải danh bạ...";

+ (ContactViewController *)instantiateWith:(id<ContactViewModelProtocol>)viewModel {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ContactViewController * selfInstance = [mainStoryboard instantiateViewControllerWithIdentifier:@"contactTableViewController"];
    selfInstance->viewModel = viewModel;
    return selfInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIAlertController * alert = [self createLoadingView: loadingMsg];
    [self presentViewController:alert animated:true completion:nil];
    
    [self->viewModel loadContacts:^(BOOL isSuccess, NSError * error, int numberOfContacts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            if (!isSuccess) {
                self->contentViewController = [self loadFailLoadingContactViewController];
            } else if (numberOfContacts == 0) {
                self->contentViewController = [self loadEmptyViewController];
            } else {
                self->contentViewController = [self loadContactTableViewController];
            }
            [self setupViews];
            [self setupEvents];
        });
    }];
}

- (void)setupViews {
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.delegate = self;
    self->contentViewController.keyboardAppearanceDelegate = self;
    
    [self addChildViewController:self->contentViewController];
    [self.view addSubview:self->contentViewController.view];
    
    self->contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self->contentViewController.view.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor].active = YES;
    [self->contentViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self->contentViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self->contentViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

- (void)setupEvents {
    [self->viewModel.search bindAndFire:^(NSString * searchText) {
        [self->viewModel searchContactWithKeyName:searchText completion:^(BOOL isNeedReload) {
            if (isNeedReload) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [((ContactTableViewController *)self->contentViewController).tableView reloadData];
                });
            }
        }];
    }];
}
     
- (UIViewController *)loadContactTableViewController {
     return [[ContactTableViewController alloc] initWithViewModel:self->viewModel];
}

- (UIViewController *)loadEmptyViewController {
    return [ResponseInformationViewController instantiateWith:ResponseViewTypeEmptyContact];
}

- (UIViewController *)loadFailLoadingContactViewController {
    return [ResponseInformationViewController instantiateWith:ResponseViewTypeFailLoadingContact];
}

- (UIAlertController *)createLoadingView: (NSString *) msg {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
    alert.view.tintColor = UIColor.blackColor;
    UIActivityIndicatorView * loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    [loadingIndicator startAnimating];
    [alert.view addSubview:loadingIndicator];
    return alert;
}

#pragma mark - Searchbar view delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self->viewModel.search.value = searchText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchBar endEditing:YES];
    return YES;
}

#pragma mark - KeyboardAppearanceProtocol view delegate
- (void)hideKeyboard {
    [self.searchBar endEditing:YES];
}

@end
