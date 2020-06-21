//
//  ContactBaseController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/21/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactBaseController.h"

#define LOADING_MESSAGE             @"Đang tải..."
#define SEARCH_PLACE_HOLDER         @"Tìm kiếm"


@interface ContactBaseController() <UISearchBarDelegate, UITextFieldDelegate>
- (UIAlertController *)createLoadingView:(NSString *) msg;
- (void)setupEvents;
@end

@implementation ContactBaseController {
    UIAlertController               * _loadingController;
}

#pragma mark - Life circle methods
- (void)loadView {
    [super loadView];
    _loadingController                      = [self createLoadingView: LOADING_MESSAGE];
    self.searchBar.delegate                 = self;
    self.searchBar.searchTextField.delegate = self;
    self.searchBar.placeholder              = SEARCH_PLACE_HOLDER;
    [self setupEvents];
    [self loadContact];
}

#pragma mark - Helper methods
- (CGSize)selectedItemSize {
    return CGSizeMake(55, 55);
}

- (void)setupEvents {
    __weak typeof(self) weakSelf = self;
    
    [self.viewModel.searchObservable binding:^(NSString * searchText) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.viewModel searchContactWithKeyName:searchText];
        }
    }];
    
    //    Listen contact had added observable
    [self.viewModel.selectedContactAddedObservable binding:^(NSNumber * index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([index intValue] == 0) {
                [self showSelectedContactsArea:YES];
            }
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[index intValue] inSection:0];
            [strongSelf addSelectedContact: indexPath];
        }
    }];
    
    //    Listen contact had removed observable
    [self.viewModel.selectedContactRemoveObservable binding:^(NSNumber * index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([strongSelf.viewModel numberOfSelectedContacts] == 0) {
                [self showSelectedContactsArea:NO];
            }
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[index intValue] inSection:0];
            [strongSelf removeSelectedContact: indexPath];
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
- (ResponseInformationViewController *)loadResponseInforView:(ResponseViewType)type {
    return [ResponseInformationViewController instantiateWith:type];
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

- (UIView *)contentView {
    NSAssert(NO, @"Subclass must implement this method");
    return nil;
}

- (void)resetAllData {
    
}

- (void)showSelectedContactsArea:(BOOL)isShow {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)addSelectedContact:(NSIndexPath *) indexPath {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)removeSelectedContact:(NSIndexPath *) indexPath {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)loadContactTable {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)loadContact {
    NSAssert(NO, @"Subclass must implement this method");
}



@end
