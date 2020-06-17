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
#import "ContactCollectionCell.h"

@interface ContactViewController () {
    UIViewController<KeyboardAppearanceProtocol>    * _contentViewController;
    HorizontalListItemView                          * _keyboardInputView;
    HorizontalListItemView                          * _contactSelectedArea;
    id<ContactViewModelProtocol>                      _viewModel;
    NSLayoutConstraint                              * _contactSelectedHeightConstraint;
}
extern NSString * const loadingMsg;

- (void) setupViews;
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
    selfInstance->_viewModel = viewModel;
    return selfInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIAlertController * alert = [self createLoadingView: loadingMsg];
    [self presentViewController:alert animated:true completion:nil];
    
    __weak typeof(self) weakSelf = self;
    
    [self->_viewModel loadContacts:^(BOOL isSuccess, NSError * error, int numberOfContacts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                
                if (!isSuccess) {
                    strongSelf->_contentViewController = [strongSelf loadFailLoadingContactViewController];
                } else if (numberOfContacts == 0) {
                    strongSelf->_contentViewController = [strongSelf loadEmptyViewController];
                } else {
                    strongSelf->_contentViewController = [strongSelf loadContactTableViewController];
                }
                [strongSelf setupViews];
            }
        });
    }];
    
    [self->_viewModel.selectedContactAddedObservable binding:^(NSNumber * index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([index intValue] == 0) {
                [strongSelf showSelectedArea];
            }
            
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[index intValue] inSection:0];
            
            [strongSelf->_contactSelectedArea.collectionView insertItemsAtIndexPaths:@[indexPath]];
            [strongSelf->_keyboardInputView.collectionView insertItemsAtIndexPaths:@[indexPath]];
                
            [strongSelf->_contactSelectedArea.collectionView scrollToItemAtIndexPath:indexPath
                                                                    atScrollPosition:UICollectionViewScrollPositionRight
                                                                            animated:YES];
            [strongSelf->_keyboardInputView.collectionView scrollToItemAtIndexPath:indexPath
                                                                  atScrollPosition:UICollectionViewScrollPositionRight
                                                                          animated:YES];
                
        }
    }];
    
    [self->_viewModel.selectedContactRemoveObservable binding:^(NSNumber * index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([strongSelf->_viewModel numberOfSelectedContacts] == 0) {
                [strongSelf hideSelectedArea];
            }
            
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[index intValue] inSection:0];
            [strongSelf->_contactSelectedArea.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            
            [strongSelf->_keyboardInputView.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }
    }];
    
}

- (void)setupViews {
    self->_keyboardInputView = [[HorizontalListItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    self->_contactSelectedArea = [[HorizontalListItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    
    self->_keyboardInputView.alpha = 0;
    
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.delegate = self;
    self->_contactSelectedArea.collectionView.delegate = self;
    self->_contactSelectedArea.collectionView.dataSource = self;
    self->_keyboardInputView.collectionView.delegate = self;
    self->_keyboardInputView.collectionView.dataSource = self;
    
    
    UINib * collectionCellNib = [UINib nibWithNibName:@"ContactCollectionCell" bundle:nil];
    [self->_contactSelectedArea.collectionView registerNib:collectionCellNib forCellWithReuseIdentifier:@"ContactCollectionCell"];
    [self->_keyboardInputView.collectionView registerNib:collectionCellNib forCellWithReuseIdentifier:@"ContactCollectionCell"];
    
    self->_contactSelectedArea.layer.shadowColor = UIColor.grayColor.CGColor;
    self->_contactSelectedArea.layer.shadowOpacity = 1;
    self->_contactSelectedArea.layer.shadowOffset = CGSizeMake(1, 0);
    
    self->_keyboardInputView.layer.shadowColor = UIColor.grayColor.CGColor;
    self->_keyboardInputView.layer.shadowOpacity = 1;
    self->_keyboardInputView.layer.shadowOffset = CGSizeMake(1, 0);
    
    self.searchBar.inputAccessoryView = self->_keyboardInputView;
    
    self->_contentViewController.keyboardAppearanceDelegate = self;
    
    [self addChildViewController:self->_contentViewController];
    [self.view addSubview:self->_contentViewController.view];
    [self.view addSubview:self->_contactSelectedArea];
    
    
    self->_contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self->_contentViewController.view.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor].active = YES;
    [self->_contentViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self->_contentViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self->_contentViewController.view.bottomAnchor constraintEqualToAnchor:self->_contactSelectedArea.topAnchor].active = YES;
    
    self->_contactSelectedArea.translatesAutoresizingMaskIntoConstraints = NO;
    self->_contactSelectedHeightConstraint = [self->_contactSelectedArea.heightAnchor constraintEqualToConstant:0];
    self->_contactSelectedHeightConstraint.active = YES;
    [self->_contactSelectedArea.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self->_contactSelectedArea.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self->_contactSelectedArea.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self.view bringSubviewToFront:self->_contactSelectedArea];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}
     
- (UIViewController *)loadContactTableViewController {
    return [[ContactTableViewController alloc] initWithViewModel:self->_viewModel];
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
    self->_viewModel.searchObservable.value = searchText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchBar endEditing:YES];
    return YES;
}

#pragma mark - KeyboardAppearanceProtocol view delegate
- (void)hideKeyboard {
    [self.searchBar endEditing:YES];
}

#pragma mark - Collection view delegate and datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_viewModel numberOfSelectedContacts];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ContactCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCollectionCell" forIndexPath:indexPath];
    
    ContactViewEntity * entity = [_viewModel selectedContactAtIndex:indexPath.item];
    
    [cell configWithEntity:entity];
    
    if (cell.delegate == nil) {
        cell.delegate = self;
    }
    
    return cell;
}

- (void)removeCell:(ContactViewEntity *)entity {
    [self->_viewModel removeSelectedContact:entity.identifier];
}

- (void)showSelectedArea {
    self->_contactSelectedHeightConstraint.constant = 80 + self.view.safeAreaInsets.bottom;
    [self->_contactSelectedArea layoutIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        self->_contactSelectedArea.alpha = 1;
        self->_keyboardInputView.alpha = 1;
    }];
}

- (void)hideSelectedArea {
    [UIView animateWithDuration:0.2 animations:^{
        self->_contactSelectedArea.alpha = 0;
        self->_keyboardInputView.alpha = 0;
    } completion:^(BOOL finished) {
        self->_contactSelectedHeightConstraint.constant = 0;
        [self->_contactSelectedArea layoutIfNeeded];
    }];
}

@end
