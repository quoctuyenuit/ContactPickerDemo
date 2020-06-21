//
//  ContactTableBaseController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/20/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableBaseController.h"
#import "Logging.h"

#define LOADING_MESSAGE         @"Đang tải..."

@interface ContactTableBaseController()
- (void) setupEvents;
@end

@implementation ContactTableBaseController {
    UIAlertController               * _loadingController;
}

@synthesize tableView;

@synthesize viewModel;

@synthesize keyboardAppearanceDelegate;

- (UITableView *)tableView {
    NSAssert(NO, @"Subclass must implement this method");
    return nil;
}

- (id<ContactViewModelProtocol>)viewModel {
    NSAssert(NO, @"Subclass must implement this method");
    return nil;
}

#pragma mark - Life circle methods
- (void)loadView {
    [super loadView];
    self.contactHadLoad                                    = NO;
    self.tableView.showsHorizontalScrollIndicator          = NO;
    self.tableView.showsVerticalScrollIndicator            = NO;
    self.tableView.separatorStyle                          = UITableViewScrollPositionNone;
    self.tableView.backgroundColor                         = UIColor.whiteColor;
    self.tableView.rowHeight                               = 66;
    _loadingController                                     = [self createLoadingView:LOADING_MESSAGE];
    [self setupEvents];
    [self loadContact];
    
}

- (void)insertCells:(NSArray<NSIndexPath *> *)indexPaths {
    @synchronized (self) {
        NSLog(@"Insert cells");
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)loadMoreContacts {
    NSAssert(NO, @"Subclass must implement this method");
}


#pragma mark - Helper methods
- (void)setupEvents {
    __weak typeof(self) weakSelf = self;
    [self.viewModel.contactBookObservable binding:^(NSNumber * number) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }
    }];
    
    [self.viewModel.dataSourceNeedReloadObservable binding:^(NSNumber * flag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                NSLog(@"dataSourceNeedReloadObservable");
                [strongSelf reloadContacts];
            }
        });
    }];
    
    [self.viewModel.cellNeedRemoveSelectedObservable binding:^(NSIndexPath * indexPath) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf contactHadRemoved:indexPath];
        }
    }];
}

- (void)loadContact {
    [UIApplication.sharedApplication.windows[0].rootViewController presentViewController:_loadingController animated:YES completion:nil];
    NSLog(@"[TableBase] begin load contacts");
    __weak typeof(self) weakSelf = self;
    [self.viewModel loadBatchOfContacts:^(NSError *error, NSArray<NSIndexPath *> *updatedIndexPaths) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf->_loadingController dismissViewControllerAnimated:YES completion:nil];
            if (error) {
                [Logging error:error.localizedDescription];
            } else {
                NSLog(@"[TableBase] loadContacts");
                [strongSelf.tableView reloadData];
                strongSelf.contactHadLoad = YES;
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
#pragma mark - Subclass methods

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Subclass must implement this method");
}

- (void)reloadContacts {
    NSAssert(NO, @"Subclass must implement this method");
}

#pragma mark - Protocol methods
- (void)resetAllData {
    
}
@end
