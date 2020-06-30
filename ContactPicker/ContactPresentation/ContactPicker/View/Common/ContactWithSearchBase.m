//
//  ContactBaseController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/21/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactWithSearchBase.h"
#import "HorizontalListItemProtocol.h"

#define LOADING_MESSAGE             @"Đang tải..."
#define SEARCH_PLACE_HOLDER         @"Tìm kiếm"


@interface ContactWithSearchBase() <UISearchBarDelegate, UITextFieldDelegate, HorizontalListItemDelegate>
- (UIAlertController *)createLoadingView:(NSString *) msg;
- (void)setupEvents;
@end

@implementation ContactWithSearchBase {
    UIAlertController               * _loadingController;
}

#pragma mark - Life circle methods
- (void)loadView {
    [super loadView];
    self.searchBar.delegate                 = self;
    self.searchBar.searchTextField.delegate = self;
    self.searchBar.placeholder              = SEARCH_PLACE_HOLDER;
    self.selectedContactView.delegate       = self;
    self.keyboardSearchbarView.delegate     = self;
    [self setupEvents];
    [self loadContact];
}

#pragma mark - Helper methods
- (CGSize)selectedItemSize {
    return CGSizeMake(55, 55);
}

- (void)setupEvents {
    __weak typeof(self) weakSelf = self;
    //    Listen contact had added observable
    [self.viewModel.selectedContactAddedObservable binding:^(NSNumber * index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([index intValue] == 0) {
                [strongSelf showSelectedContactsArea:YES];
            }
            [strongSelf.selectedContactView insertItemAtIndex: [index integerValue]];
            [strongSelf.keyboardSearchbarView insertItemAtIndex: [index integerValue]];
        }
    }];
    
    //    Listen contact had removed observable
    [self.viewModel.selectedContactRemoveObservable binding:^(NSNumber * index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([strongSelf.viewModel numberOfSelectedContacts] == 0) {
                [strongSelf showSelectedContactsArea:NO];
            }
            [strongSelf.selectedContactView removeItemAtIndex: [index integerValue]];
            [strongSelf.keyboardSearchbarView removeItemAtIndex: [index integerValue]];
        }
    }];
}

- (UIAlertController *)createLoadingView:(NSString *) msg {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
    alert.view.tintColor = UIColor.blackColor;
    UIActivityIndicatorView * loadingIndicator  = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
    loadingIndicator.hidesWhenStopped           = YES;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    [loadingIndicator startAnimating];
    [alert.view addSubview:loadingIndicator];
    return alert;
}

#pragma mark - Helper methods
- (ResponseInformationView *)loadResponseInforView:(ResponseViewType)type {
    return [[ResponseInformationView alloc] initWithType:type];
}

#pragma mark - KeyboardAppearanceProtocol methods
- (void)hideKeyboard {
    [self.searchBar endEditing:YES];
}

#pragma mark - SearchbarDelegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.viewModel.searchObservable.value = searchText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchBar endEditing:YES];
    return YES;
}

#pragma mark - ContactCollectionCellDelegate methods
- (void)removeCell:(ContactViewEntity *)entity {
    [self.viewModel removeSelectedContact:entity.identifier];
}

#pragma mark - Subclass methods
- (id<ContactViewModelProtocol>)viewModel {
    NSAssert(NO, @"Subclass must implement this method");
    return nil;
}

- (UISearchBar *)searchBar {
    NSAssert(NO, @"Subclass must implement this method");
    return nil;
}

- (id<HorizontalListItemProtocol>)selectedContactView {
    NSAssert(NO, @"Subclass must implement this method");
    return nil;
}

- (id<HorizontalListItemProtocol>)keyboardSearchbarView {
    NSAssert(NO, @"Subclass must implement this method");
    return nil;
}

- (void)showSelectedContactsArea:(BOOL)isShow {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)loadContact {
    NSAssert(NO, @"Subclass must implement this method");
}

#pragma mark - HorizontalListItemDelegate methods
- (ContactViewEntity *)horizontalListItem:(id<HorizontalListItemProtocol>)listItemView entityForIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel selectedContactAtIndex:indexPath.item];
}

- (NSInteger)horizontalListItem:(id<HorizontalListItemProtocol>)listItemView numberOfItemAtSection:(NSInteger)section {
    return [self.viewModel numberOfSelectedContacts];
}

- (void)removeCellWithContact:(ContactViewEntity *)contact {
    [self.viewModel removeSelectedContact:contact.identifier];
}
@end
