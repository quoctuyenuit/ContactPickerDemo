//
//  ContactWithSearchComponent.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/24/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_COMPONENTKIT
#import "ContactWithSearchComponentKit.h"
#import <ComponentKit/ComponentKit.h>
#import <UIKit/UIKit.h>
#import "HorizontalListItemView.h"

#import "ContactViewModel.h"
#import "ContactBusinessLayer.h"
#import "ContactAdapter.h"
#import "ContactTableControllerComponentKit.h"

#import "ContactCollectionCell.h"

#define REUSE_IDENTIIER     @"ContactCollectionCell"

@implementation ContactWithSearchComponentKit {
    UISearchBar                                     * _searchBar;
    UIViewController                                * _contentViewController;
    HorizontalListItemView                          * _contactSelectedKeyboardView;
    HorizontalListItemView                          * _contactSelectedView;
    id<ContactViewModelProtocol>                      _viewModel;
    NSLayoutConstraint                              * _contactSelectedHeightConstraint;
}
- (instancetype)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel                          = [[ContactViewModel alloc] initWithBus: [[ContactBusinessLayer alloc] initWithAdapter:[[ContactAdapter alloc] init]]];
        _searchBar                          = [[UISearchBar alloc] init];
        _searchBar.searchBarStyle           = UISearchBarStyleMinimal;
        _searchBar.barTintColor             = UIColor.clearColor;
        _searchBar.backgroundColor          = UIColor.clearColor;
        [self initElements];
        [self showSelectedContactsArea:NO];
    }
    return self;
}

- (void)initElements {
    _contactSelectedView                = [[HorizontalListItemView alloc] initWithFrame:CGRectZero];
    _contactSelectedKeyboardView        = [[HorizontalListItemView alloc] initWithFrame:CGRectMake(0, 0, 0, 80)];
    
    _contactSelectedView.layer.shadowColor      = UIColor.grayColor.CGColor;
    _contactSelectedView.layer.shadowOpacity    = 1;
    _contactSelectedView.layer.shadowOffset     = CGSizeMake(1, 0);
    
    _contactSelectedKeyboardView.layer.shadowColor      = UIColor.grayColor.CGColor;
    _contactSelectedKeyboardView.layer.shadowOpacity    = 1;
    _contactSelectedKeyboardView.layer.shadowOffset     = CGSizeMake(1, 0);
 
    _searchBar.inputAccessoryView = _contactSelectedKeyboardView;
    
#if DEBUG_MODE
    _searchBar.backgroundColor                      = UIColor.redColor;
    _contactSelectedView.backgroundColor            = UIColor.yellowColor;
    _contactSelectedKeyboardView.backgroundColor    = UIColor.orangeColor;
#endif
}

#pragma mark - Layout views
- (void)layoutViews {
    [self.view addSubview:_searchBar];
    [self.view addSubview:_contentViewController.view];
    [self.view addSubview:_contactSelectedView];
    
    _searchBar.translatesAutoresizingMaskIntoConstraints            = NO;
    _contentViewController.view.translatesAutoresizingMaskIntoConstraints          = NO;
    _contactSelectedView.translatesAutoresizingMaskIntoConstraints  = NO;
    
    [_searchBar.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active                               = YES;
    [_searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active                             = YES;
    [_searchBar.heightAnchor constraintEqualToConstant:SEARCH_BAR_HEIGHT].active                                    = YES;
    
    [_contentViewController.view.topAnchor constraintEqualToAnchor:_searchBar.bottomAnchor].active                 = YES;
    [_contentViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active             = YES;
    [_contentViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active           = YES;
    [_contentViewController.view.bottomAnchor constraintEqualToAnchor:_contactSelectedView.topAnchor].active       = YES;
    
    _contactSelectedHeightConstraint = [self->_contactSelectedView.heightAnchor constraintEqualToConstant:0];
    [_contactSelectedView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active     = YES;
    [_contactSelectedView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active   = YES;
    [_contactSelectedView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active       = YES;
    _contactSelectedHeightConstraint.active                                                         = YES;
    
    [self.view bringSubviewToFront:_contactSelectedView];
}

#pragma mark - Subclass methods
- (id<ContactViewModelProtocol>)viewModel {
    return _viewModel;
}

- (UISearchBar *)searchBar {
    return _searchBar;
}

- (id<HorizontalListItemProtocol>)selectedContactView {
    return _contactSelectedView;
}

- (id<HorizontalListItemProtocol>)keyboardSearchbarView {
    return _contactSelectedKeyboardView;
}

- (void)resetAllData {
    
}

- (void)showSelectedContactsArea:(BOOL)isShow {
    _contactSelectedHeightConstraint.constant = isShow ? 80 + self.view.safeAreaInsets.bottom : 0;
    [_contactSelectedView layoutIfNeeded];
    
    weak_self
    [UIView animateWithDuration:0.2 animations:^{
        strong_self
        if (strongSelf) {
            strongSelf->_contactSelectedView.alpha = isShow ? 1 : 0;
            strongSelf->_contactSelectedKeyboardView.alpha = isShow ? 1 : 0;
        }
    }];
}

- (void)loadContact {
//    __weak typeof(self) weakSelf = self;
//    [_viewModel loadContacts:^(BOOL isSuccess, NSError *error, NSUInteger numberOfContacts) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        if (strongSelf) {
//            if (error) {
//                strongSelf->_contentViewController = [strongSelf wrapResponseViewIntoController:ResponseViewTypeFailLoadingContact];
//            } else if (numberOfContacts == 0) {
//                strongSelf->_contentViewController = [strongSelf wrapResponseViewIntoController:ResponseViewTypeEmptyContact];
//            } else {
//                UIViewController<KeyboardAppearanceProtocol> *table = [[ContactTableControllerComponentKit alloc] initWithViewModel:self->_viewModel];
//                table.keyboardAppearanceDelegate = self;
//                strongSelf->_contentViewController = table;
//            }
//            
//            [strongSelf addChildViewController:strongSelf->_contentViewController];
//            [strongSelf layoutViews];
//        }
//    }];
}

- (UIViewController *)wrapResponseViewIntoController:(ResponseViewType) type {
    ResponseInformationView *responseView = [self loadResponseInforView:type];
    responseView.keyboardAppearanceDelegate         = self;
    UIViewController * vc                           = [[UIViewController alloc] init];
    [vc.view addSubview:responseView];
    
    responseView.translatesAutoresizingMaskIntoConstraints                          = NO;
    [responseView.topAnchor constraintEqualToAnchor:vc.view.topAnchor].active       = YES;
    [responseView.leftAnchor constraintEqualToAnchor:vc.view.leftAnchor].active     = YES;
    [responseView.rightAnchor constraintEqualToAnchor:vc.view.rightAnchor].active   = YES;
    [responseView.bottomAnchor constraintEqualToAnchor:vc.view.bottomAnchor].active = YES;
    return vc;
}

@end
#endif
