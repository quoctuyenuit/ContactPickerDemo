//
//  ContactTableBaseController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/20/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableBaseController.h"
#import "ContactDefine.h"
#import "NSErrorExtension.h"
#define LOADING_MESSAGE         @"Đang tải..."
#define LOG_MSG_HEADER          @"ContactBaseTable"

@interface ContactTableBaseController()
- (void) setupEvents;
@end

@implementation ContactTableBaseController {
    UIAlertController               * _loadingController;
}

@synthesize viewModel;

@synthesize keyboardAppearanceDelegate;

#pragma mark - Subclass must implement methods
- (id<ContactViewModelProtocol>)viewModel {
    NSAssert(NO, @"Subclass must implement this method");
    return nil;
}

- (void)setupBaseViews {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)setupDatasets {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)showErrorView:(ResponseViewType)type {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)reloadTable {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)insertCells:(NSArray<NSIndexPath *> *)indexPaths forEntities:(NSArray<ContactViewEntity *> *)entities {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)removeCells:(NSArray<NSIndexPath *> *)indexPaths {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Subclass must implement this method");
}

#pragma mark - Life circle methods
- (void)loadView {
    [super loadView];
    self.contactHadLoad = NO;
    [self setupBaseViews];
    [self setupDatasets];
    [self setupEvents];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContact];
}

#pragma mark - Helper methods
- (void)setupEvents {
    weak_self
    [self.viewModel.contactBookObservable binding:^(NSNumber * number) {
        strong_self
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf reloadTable];
            });
        }
    }];
    
    [self.viewModel.searchObservable binding:^(NSString * searchText) {
        strong_self
        if (strongSelf) {
            [strongSelf.viewModel searchContactWithKeyName:searchText block:^(NSArray<ContactViewEntity *> * _Nullable contacts, NSArray<NSIndexPath *> * _Nullable indexPaths, NSError * _Nullable error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf && !error) {
                    [strongSelf insertCells:indexPaths forEntities:contacts];
                }
            }];
        }
    }];
    
    [self.viewModel.dataSourceNeedReloadObservable binding:^(NSArray<NSIndexPath *> * removedIndexPaths) {
        strong_self
        if (strongSelf) {
            [strongSelf removeCells:removedIndexPaths];
        }
    }];
    
    [self.viewModel.cellNeedRemoveSelectedObservable binding:^(NSIndexPath * indexPath) {
        strong_self
        if (strongSelf) {
            [strongSelf contactHadRemoved:indexPath];
        }
    }];
}

- (void)loadContact {
    _loadingController = [self createLoadingView:LOADING_MESSAGE];
    [UIApplication.sharedApplication.windows[0].rootViewController presentViewController:_loadingController animated:YES completion:nil];
    
    DebugLog(@"[%@] begin load contact", LOG_MSG_HEADER);
    weak_self
    [self.viewModel loadContactsWithBlock:^(NSArray<ContactViewEntity *> * _Nullable contacts,
                                            NSArray<NSIndexPath *> * _Nullable indexPaths,
                                            NSError * _Nullable error) {
        strong_self
        if (strongSelf) {
            [strongSelf->_loadingController dismissViewControllerAnimated:YES completion:nil];
            if (!error) {
                weakSelf.contactHadLoad = YES;
                [weakSelf insertCells:indexPaths forEntities:contacts];
            } else {
                switch (error.code) {
                    case NO_CONTENT_ERROR_CODE:
                        [weakSelf showErrorView:ResponseViewTypeEmptyContact];
                        break;
                    case FAILT_ERROR_CODE:
                        [weakSelf showErrorView:ResponseViewTypeFailLoadingContact];
                        break;
                    default:
                        [weakSelf showErrorView:ResponseViewTypeSomethingWrong];
                        break;
                }
            }
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

#pragma mark - Protocol methods
- (void)resetAllData {
    
}
@end
