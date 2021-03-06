//
//  ContactTableNodeController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactDefine.h"
#if BUILD_TEXTURE

#import "ContactTableControllerTexture.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "ContactViewEntity.h"
#import "ContactTableCellNode.h"
#import "ContactDefine.h"
#import "ContactGlobalConfigure.h"

#define DEBUG_MODE                          1

#define LOADING_MSG                         @"Đang tải danh bạ..."

@interface ContactTableControllerTexture () <ASTableDelegate, ASTableDataSource, KeyboardAppearanceDelegate>
@end

@implementation ContactTableControllerTexture {
//    ASTableNode                 * _tableNode;
    ASDisplayNode                   *_contentNode;
    id<ContactViewModelProtocol>    _viewModel;
}


@synthesize keyboardAppearanceDelegate;

#pragma mark - Lifecycle

- (instancetype) initWithViewModel: (id<ContactViewModelProtocol>) viewModel {
    self = [super initWithNode:[[ASDisplayNode alloc] init]];
    if (self) {
        _viewModel            = viewModel;
        _tableNode              = [[ASTableNode alloc] init];
        _tableNode.delegate   = self;
        _tableNode.dataSource = self;
        
#if DEBUG_MODE
        self.node.backgroundColor       = UIColor.greenColor;
#endif
        self.node.automaticallyManagesSubnodes = YES;
        weak_self
        self.node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            return [ASWrapperLayoutSpec wrapperWithLayoutElement:[weakSelf.tableNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.flexGrow = 10;
                style.flexShrink = 1;
                style.preferredSize = weakSelf.node.calculatedSize;
            }]];
        };
    }
    return self;
}

#pragma mark - ASTableDatasource methods
- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return [_viewModel numberOfSection];
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    if (!self.contactHadLoad)
        return 0;
    return [_viewModel numberOfContactInSection:section];
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak ContactViewEntity * contact = [_viewModel contactAtIndex:indexPath];
    return ^ASCellNode * {
        return [[ContactTableCellNode alloc] initWithContact:contact];
    };
}

- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableNode deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactTableCellNode * cell = (ContactTableCellNode *)[tableNode nodeForRowAtIndexPath:indexPath];
    [cell setSelect];
    
    [_viewModel selectectContactAtIndex:indexPath];
    
    if (self.keyboardAppearanceDelegate && [self.keyboardAppearanceDelegate respondsToSelector:@selector(hideKeyboard)])
        [self.keyboardAppearanceDelegate hideKeyboard];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [_viewModel sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_viewModel numberOfContactInSection:section] > 0 ? [_viewModel titleForHeaderInSection:section] : nil;
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
    _tableNode.view.rowHeight                               = [ContactGlobalConfigure globalConfig].contactHeight;
}

- (void)setupDatasets {
    
}

- (void)showErrorView:(ResponseViewType)type {
    [_tableNode removeFromSupernode];
    
    ResponseInformationView * resView = [[ResponseInformationView alloc] initWithType:type];
    resView.keyboardAppearanceDelegate = self;

    _contentNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
        return resView;
    }];
    weak_self
    self.node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
        return [ASWrapperLayoutSpec wrapperWithLayoutElement:[weakSelf.contentNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
            style.flexGrow = 10;
            style.flexShrink = 1;
            style.preferredSize = weakSelf.node.calculatedSize;
        }]];
    };
}

- (void)reloadTable {
    [_tableNode reloadData];
}

- (void)reloadTableWithDeletedIndexes:(NSArray<NSIndexPath *> *)deletedIndexPaths addedIndexes:(NSArray<NSIndexPath *> *)addedIndexPaths {
    [_tableNode reloadData];
}

- (void)removeCells:(NSArray<NSIndexPath *> *)indexPaths {
    DebugLog(@"[%@] begin remove cell from %ld indexs", LOG_MSG_HEADER, indexPaths.count);
    [_tableNode deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    ContactTableCellNode * cell = [_tableNode nodeForRowAtIndexPath:indexPath];
    [cell setSelect];
}

#pragma mark - KeyboardAppearanceDelegate methods
- (void)hideKeyboard {
    if (self.keyboardAppearanceDelegate && [self.keyboardAppearanceDelegate respondsToSelector:@selector(hideKeyboard)])
        [self.keyboardAppearanceDelegate hideKeyboard];
}
@end


#endif
