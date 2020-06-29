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
#define LOG_MSG_HEADER          @"ContactBaseTable"

@interface ContactTableBaseController()
- (void) setupEvents;
@end

@implementation ContactTableBaseController {
    UIAlertController               * _loadingController;
#if DEBUG_MEM_ENABLE
    NSTimer                         * _autoFetchBatchTimer;
#endif
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

- (void)fetchBatchContactWithBlock:(void (^_Nullable)(NSError * error))block {
    NSLog(@"[%@] begin fetch batch", LOG_MSG_HEADER);
    __weak typeof(self) weakSelf = self;
    [self.viewModel loadBatchOfContacts:^(NSError *error, NSArray<NSIndexPath *> *updatedIndexPaths, NSArray<ContactViewEntity *> * entities) {
        NSLog(@"[%@] end fetch batch", LOG_MSG_HEADER);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error) {
                [Logging error:error.localizedDescription];
            } else {
                [strongSelf insertCells:updatedIndexPaths forEntities:entities];
            }
            if (block)
                block(error);
        }
    }];
}

#pragma mark - Life circle methods
- (void)loadView {
    [super loadView];
    self.contactHadLoad = NO;
    [self setupBaseViews];
    [self setupDatasets];
    [self setupEvents];
#if DEBUG_MEM_ENABLE
//    Auto fetch contact;
    _autoFetchBatchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                            target:self
                                                          selector:@selector(autoFetchBatchTimerAction:)
                                                          userInfo:nil
                                                           repeats:YES];
#endif
}

#if DEBUG_MEM_ENABLE
- (void)autoFetchBatchTimerAction:(NSTimer *) timer {
    __weak typeof(self) weakSelf = self;
    [self fetchBatchContactWithBlock:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && error) {
            [strongSelf->_autoFetchBatchTimer invalidate];
            strongSelf-> _autoFetchBatchTimer = nil;
        }
    }];
}
#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContact];
}

#pragma mark - Helper methods
- (void)setupEvents {
    __weak typeof(self) weakSelf = self;
    [self.viewModel.contactBookObservable binding:^(NSNumber * number) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf reloadTable];
            });
        }
    }];
    
    [self.viewModel.searchObservable binding:^(NSString * searchText) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.viewModel searchContactWithKeyName:searchText block:^{
                [strongSelf fetchBatchContactWithBlock:nil];
            }];
        }
    }];
    
    [self.viewModel.dataSourceNeedReloadObservable binding:^(NSArray<NSIndexPath *> * removedIndexPaths) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf removeCells:removedIndexPaths];
        }
    }];
    
    [self.viewModel.cellNeedRemoveSelectedObservable binding:^(NSIndexPath * indexPath) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf contactHadRemoved:indexPath];
        }
    }];
}

- (void)loadContact {
    _loadingController = [self createLoadingView:LOADING_MESSAGE];
    [UIApplication.sharedApplication.windows[0].rootViewController presentViewController:_loadingController animated:YES completion:nil];
    
    NSLog(@"[%@] begin load batch", LOG_MSG_HEADER);
    __weak typeof(self) weakSelf = self;
    [self.viewModel loadBatchOfContacts:^(NSError *error, NSArray<NSIndexPath *> *updatedIndexPaths, NSArray<ContactViewEntity *> * entities) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf->_loadingController dismissViewControllerAnimated:YES completion:nil];
            if (error) {
                [Logging error:error.localizedDescription];
            } else {
                NSLog(@"[%@] end load batch", LOG_MSG_HEADER);
                strongSelf.contactHadLoad = YES;
                [strongSelf insertCells:updatedIndexPaths forEntities:entities];
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
