//
//  ContactTableNodeController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableNodeController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "ContactViewEntity.h"
#import "ContactTableCellNode.h"
#import "Logging.h"


#define LOADING_MSG                         @"Đang tải danh bạ..."

@interface ContactTableNodeController () <ASTableDelegate, ASTableDataSource>
@end

@implementation ContactTableNodeController {
    ASTableNode                 * _tableNode;
    id<ContactViewModelProtocol>  _viewModel;
}


@synthesize keyboardAppearanceDelegate;

#pragma mark - Lifecycle

- (instancetype) initWithViewModel: (id<ContactViewModelProtocol>) viewModel {
    _tableNode                  = [[ASTableNode alloc] init];
    self = [super initWithNode:self->_tableNode];
    
    if (self) {
        _viewModel            = viewModel;
        _tableNode.delegate   = self;
        _tableNode.dataSource = self;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    _tableNode.leadingScreensForBatching                    = AUTO_TAIL_LOADING_NUM_SCREENFULS;
}

#pragma mark - ASTableDatasource methods
- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return [self->_viewModel numberOfSection];
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return [self->_viewModel numberOfContactInSection:section];
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactViewEntity * contact = [self->_viewModel contactAtIndex:indexPath];
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode * {
        return [[ContactTableCellNode alloc] initWithContact:contact];
    };
    return ASCellNodeBlock;
}

- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableNode deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactTableCellNode * cell = (ContactTableCellNode *)[tableNode nodeForRowAtIndexPath:indexPath];
    [cell setSelect];
    
    [self->_viewModel selectectContactAtIndex:indexPath];
    
    [self.keyboardAppearanceDelegate hideKeyboard];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self->_viewModel getAllSectionNames];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self->_viewModel numberOfContactInSection:section] > 0 ? [self->_viewModel titleForHeaderInSection:section] : nil;
}

- (void)tableNode:(ASTableNode *)tableNode willBeginBatchFetchWithContext:(ASBatchContext *)context {
    NSLog(@"ContactTableNodeController] batFetching");
    [context beginBatchFetching];
    [self loadBatchContacts:context];
}

#pragma mark - Parent methods
- (UITableView *)tableView {
    return _tableNode.view;
}

- (id<ContactViewModelProtocol>)viewModel {
    return _viewModel;
}

- (void)loadMoreContacts {
    [self loadBatchContacts:nil];
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    ContactTableCellNode * cell = [_tableNode nodeForRowAtIndexPath:indexPath];
    [cell setSelect];
}

- (void)reloadContacts {
    [_tableNode reloadData];
    NSIndexPath * firstIndex = [_viewModel firstContactOnView];
    if (firstIndex) {
        [_tableNode scrollToRowAtIndexPath:firstIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - Helper methods

- (void)loadBatchContacts: (ASBatchContext * _Nullable) context {
    NSLog(@"[ContactTableNodeController] load batch");
    __weak typeof(self) weakSelf = self;
    [_viewModel loadBatchOfContacts:^(NSError *error, NSArray<NSIndexPath *> *updatedIndexPaths) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error) {
                [Logging error:error.localizedDescription];
            } else {
                [strongSelf insertCells:updatedIndexPaths];
            }
            
            if (context) {
                [context completeBatchFetching:YES];
            }
        }
    }];
}
@end
