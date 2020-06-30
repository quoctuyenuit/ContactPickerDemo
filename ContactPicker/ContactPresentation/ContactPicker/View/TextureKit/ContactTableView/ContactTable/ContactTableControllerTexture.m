//
//  ContactTableNodeController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableControllerTexture.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "ContactViewEntity.h"
#import "ContactTableCellNode.h"
#import "ContactDefine.h"

#define LOADING_MSG                         @"Đang tải danh bạ..."
#define LOG_MSG_HEADER                      @"ContactTableTexture"

@interface ContactTableControllerTexture () <ASTableDelegate, ASTableDataSource>
@end

@implementation ContactTableControllerTexture {
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

#pragma mark - ASTableDatasource methods
- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return [self->_viewModel numberOfSection];
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return [self->_viewModel numberOfContactInSection:section];
}

//- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
//    ContactViewEntity * contact = [self->_viewModel contactAtIndex:indexPath];
//    __weak typeof(contact) weakContact = contact;
//    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode * {
//        return [[ContactTableCellNode alloc] initWithContact:weakContact];
//    };
//    return ASCellNodeBlock;
//}



- (ASCellNode *)tableNode:(ASTableNode *)tableNode nodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactViewEntity * contact = [self->_viewModel contactAtIndex:indexPath];
    return [[ContactTableCellNode alloc] initWithContact:contact];
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
    if (!self.contactHadLoad) {
        [context completeBatchFetching:YES];
        return;
    }
    DebugLog(@"[%@] begin batchFetchWithContext", LOG_MSG_HEADER);
    [context beginBatchFetching];
    [self loadBatchContacts:context];
}

#pragma mark - Parent methods
- (id<ContactViewModelProtocol>)viewModel {
    return _viewModel;
}

- (void)setupBaseViews {
    _tableNode.leadingScreensForBatching                    = AUTO_TAIL_LOADING_NUM_SCREENFULS;
    _tableNode.view.showsHorizontalScrollIndicator          = NO;
    _tableNode.view.showsVerticalScrollIndicator            = NO;
    _tableNode.view.separatorStyle                          = UITableViewScrollPositionNone;
    _tableNode.view.backgroundColor                         = UIColor.whiteColor;
    _tableNode.view.rowHeight                               = 66;
}

- (void)setupDatasets {
    
}

- (void)reloadTable {
    [_tableNode reloadData];
    NSIndexPath * firstIndex = [_viewModel firstContactOnView];
    if (firstIndex) {
        DebugLog(@"[%@] reload table - scroll top at: [%ld, %ld], current cell in this section is: %ld", LOG_MSG_HEADER, firstIndex.row, firstIndex.section, [_tableNode numberOfRowsInSection:firstIndex.section]);
        [_tableNode scrollToRowAtIndexPath:firstIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)insertCells:(NSArray<NSIndexPath *> *)indexPaths forEntities:(NSArray<ContactViewEntity *> *)entities {
    DebugLog(@"[%@] begin insert cell from %ld indexs", LOG_MSG_HEADER, indexPaths.count);
    [_tableNode insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
#if DEBUG_MEM_ENABLE
    NSInteger cells = 0;
    for (NSInteger section = 0; section < [_tableNode numberOfSections]; section++) {
        cells += [_tableNode numberOfRowsInSection:section];
    }
    DebugLog(@"[%@] current cells: %ld", LOG_MSG_HEADER, cells);
#endif
}

- (void)removeCells:(NSArray<NSIndexPath *> *)indexPaths {
    DebugLog(@"[%@] begin remove cell from %ld indexs", LOG_MSG_HEADER, indexPaths.count);
    [_tableNode reloadData];
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    ContactTableCellNode * cell = [_tableNode nodeForRowAtIndexPath:indexPath];
    [cell setSelect];
}


#pragma mark - Helper methods
- (void)loadBatchContacts: (ASBatchContext * _Nullable) context {
    [self fetchBatchContactWithBlock:^(NSError * error) {
        [context completeBatchFetching:YES];
    }];
}
@end
