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
    UIViewController<KeyboardAppearanceProtocol> * contentViewController;
    HorizontalListItemView * keyboardInputView;
    HorizontalListItemView * contactSelectedArea;
    ContactViewModel * viewModel;
    NSLayoutConstraint * contactSelectedHeightConstraint;
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
        });
    }];
    
    [self->viewModel.selectedContactAddedObservable binding:^(NSNumber * index) {
        if ([index intValue] == 0) {
            [self showSelectedArea];
        }
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[index intValue] inSection:0];
        
        [self->contactSelectedArea.collectionView insertItemsAtIndexPaths:@[indexPath]];
        [self->keyboardInputView.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [self->contactSelectedArea.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight
                                                                     animated:NO];
            [self->keyboardInputView.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight
                                                                   animated:NO];
            
        }];
    }];
    
    [self->viewModel.selectedContactRemoveObservable binding:^(NSNumber * index) {
        if (self->viewModel.listSelectedContacts.count == 0) {
            [self hideSelectedArea];
        }
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[index intValue] inSection:0];
        [self->contactSelectedArea.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
        [self->keyboardInputView.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }];
    
}

- (void)setupViews {
    self->keyboardInputView = [[HorizontalListItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    self->contactSelectedArea = [[HorizontalListItemView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    
    self->keyboardInputView.alpha = 0;
    
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.delegate = self;
    self->contactSelectedArea.collectionView.delegate = self;
    self->contactSelectedArea.collectionView.dataSource = self;
    self->keyboardInputView.collectionView.delegate = self;
    self->keyboardInputView.collectionView.dataSource = self;
    
    
    UINib * collectionCellNib = [UINib nibWithNibName:@"ContactCollectionCell" bundle:nil];
    [self->contactSelectedArea.collectionView registerNib:collectionCellNib forCellWithReuseIdentifier:@"ContactCollectionCell"];
    [self->keyboardInputView.collectionView registerNib:collectionCellNib forCellWithReuseIdentifier:@"ContactCollectionCell"];
    
    self->contactSelectedArea.layer.shadowColor = UIColor.grayColor.CGColor;
    self->contactSelectedArea.layer.shadowOpacity = 1;
    self->contactSelectedArea.layer.shadowOffset = CGSizeMake(1, 0);
    
    self->keyboardInputView.layer.shadowColor = UIColor.grayColor.CGColor;
    self->keyboardInputView.layer.shadowOpacity = 1;
    self->keyboardInputView.layer.shadowOffset = CGSizeMake(1, 0);
    
    self.searchBar.inputAccessoryView = self->keyboardInputView;
    
    self->contentViewController.keyboardAppearanceDelegate = self;
    
    [self addChildViewController:self->contentViewController];
    [self.view addSubview:self->contentViewController.view];
    [self.view addSubview:self->contactSelectedArea];
    
    
    self->contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self->contentViewController.view.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor].active = YES;
    [self->contentViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self->contentViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self->contentViewController.view.bottomAnchor constraintEqualToAnchor:self->contactSelectedArea.topAnchor].active = YES;
    
    self->contactSelectedArea.translatesAutoresizingMaskIntoConstraints = NO;
    self->contactSelectedHeightConstraint = [self->contactSelectedArea.heightAnchor constraintEqualToConstant:0];
    self->contactSelectedHeightConstraint.active = YES;
    [self->contactSelectedArea.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self->contactSelectedArea.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self->contactSelectedArea.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self.view bringSubviewToFront:self->contactSelectedArea];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
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
    self->viewModel.searchObservable.value = searchText;
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
    return self->viewModel.listSelectedContacts.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ContactCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCollectionCell" forIndexPath:indexPath];
    
    ContactViewEntity * entity = self->viewModel.listSelectedContacts[(int)indexPath.item];
    
    [cell config:entity];
    
    if (cell.delegate == nil) {
        cell.delegate = self;
    }
    
    return cell;
}

- (void)removeCell:(ContactViewEntity *)entity {
    [self->viewModel removeSelectedContact:entity.identifier];
}

- (void)showSelectedArea {
    self->contactSelectedHeightConstraint.constant = 80 + self.view.safeAreaInsets.bottom;
    [self->contactSelectedArea layoutIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        self->contactSelectedArea.alpha = 1;
        self->keyboardInputView.alpha = 1;
    }];
}

- (void)hideSelectedArea {
    [UIView animateWithDuration:0.2 animations:^{
        self->contactSelectedArea.alpha = 0;
        self->keyboardInputView.alpha = 0;
    } completion:^(BOOL finished) {
        self->contactSelectedHeightConstraint.constant = 0;
        [self->contactSelectedArea layoutIfNeeded];
    }];
}

@end
