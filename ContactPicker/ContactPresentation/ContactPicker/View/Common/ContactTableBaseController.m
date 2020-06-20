//
//  ContactTableBaseController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/20/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableBaseController.h"
#import "Logging.h"

@interface ContactTableBaseController()
- (void) setupEvents;
@end

@implementation ContactTableBaseController

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
    self.tableView.showsHorizontalScrollIndicator          = NO;
    self.tableView.showsVerticalScrollIndicator            = NO;
    self.tableView.separatorStyle                          = UITableViewScrollPositionNone;
    self.tableView.backgroundColor                         = UIColor.whiteColor;
    self.tableView.rowHeight                               = 60;
    [self setupEvents];
    [self loadContact];
}

- (void)insertCells:(NSArray<NSIndexPath *> *)indexPaths {
    dispatch_sync(dispatch_get_main_queue(), ^{
        @synchronized (self.viewModel.contactsOnView) {
            NSLog(@"Insert cells");
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    });
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
    
    [self.viewModel.searchObservable binding:^(NSString * searchText) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.viewModel searchContactWithKeyName:searchText];
        }
    }];
    
    [self.viewModel.dataSourceNeedReloadObservable binding:^(NSNumber * flag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
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
    __weak typeof(self) weakSelf = self;
    [self.viewModel loadBatchOfContacts:^(NSError *error, NSArray<NSIndexPath *> *updatedIndexPaths) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (error) {
                    [Logging error:error.localizedDescription];
                } else {
                    [strongSelf.tableView reloadData];
                }
            }
        });
    }];
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
