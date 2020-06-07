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

@interface ContactViewController () {
    UIViewController<KeyboardAppearanceProtocol> * contentViewController;
    ContactViewModel * viewModel;
}
- (void) setupViews;
- (void) setupEvents;
- (UIViewController<KeyboardAppearanceProtocol> *) loadContactTableViewController;
- (UIViewController<KeyboardAppearanceProtocol> *) loadFailLoadingContactViewController;
- (UIViewController<KeyboardAppearanceProtocol> *) loadEmptyViewController;
@end

@implementation ContactViewController

+ (ContactViewController *)instantiateWith:(id<ContactViewModelProtocol>)viewModel {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ContactViewController * selfInstance = [mainStoryboard instantiateViewControllerWithIdentifier:@"contactTableViewController"];
    selfInstance->viewModel = viewModel;
    return selfInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self->viewModel loadContacts:^(BOOL isSuccess, int numberOfContacts) {
        dispatch_async(dispatch_get_main_queue(), ^{
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
