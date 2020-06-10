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
        });
    }];
    
    [self->viewModel.numberOfSelectedContacts bindAndFire:^(NSNumber * number) {
        if ([number intValue] == 0) {
            self.contactSelectedArea.alpha = 0;
        } else {
            self.contactSelectedArea.alpha = 1;
        }
    }];
}

- (void)setupViews {
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UINib * collectionCellNib = [UINib nibWithNibName:@"ContactCollectionCell" bundle:nil];
    [self.collectionView registerNib:collectionCellNib forCellWithReuseIdentifier:@"ContactCollectionCell"];
    
    self.contactSelectedArea.layer.shadowColor = UIColor.grayColor.CGColor;
    self.contactSelectedArea.layer.shadowOpacity = 1;
    self.contactSelectedArea.layer.shadowOffset = CGSizeMake(1, 0);
    
//    self.searchBar.inputAccessoryView = [self.contactSelectedArea copy];
    
    
    self->contentViewController.keyboardAppearanceDelegate = self;
    
    [self addChildViewController:self->contentViewController];
    [self.view addSubview:self->contentViewController.view];
    
    self->contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self->contentViewController.view.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor].active = YES;
    [self->contentViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self->contentViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self->contentViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}
     
- (UIViewController *)loadContactTableViewController {
    ContactTableViewController * contactTable = [[ContactTableViewController alloc] initWithViewModel:self->viewModel];
    contactTable.contactDelegate = self;
    return contactTable;
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

- (void)didSelectContact:(ContactViewEntity *)contact {
    [self.collectionView reloadData];
    [self.view bringSubviewToFront:self.contactSelectedArea];
}

#pragma mark Collection view delegate and datasource
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
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected");
}
@end
