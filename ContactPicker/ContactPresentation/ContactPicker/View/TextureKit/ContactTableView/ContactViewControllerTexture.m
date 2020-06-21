//
//  ContactViewControllerTexture.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactViewControllerTexture.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "KeyboardAppearanceDelegate.h"
#import "ContactTableNodeController.h"
#import "SearchNode.h"
#import "ContactCollectionCellNode.h"
#import "HorizontalListNode.h"
#import "ResponseInformationViewController.h"

#import "ContactViewModel.h"
#import "ContactBus.h"
#import "ContactAdapter.h"

#define DEBUG_MODE              0

#define LOADING_MSG             @"Đang tải..."

@interface ContactViewControllerTexture()
@end

@implementation ContactViewControllerTexture {
    BOOL                                              _isShowSelected;
    id<ContactViewModelProtocol>                      _viewModel;
    ASViewController                                * _contentViewController;
    SearchNode                                      * _searchNode;
    ASDisplayNode                                   * _contentNode;
    HorizontalListNode                              * _contactSelectedView;
    HorizontalListNode                              * _contactSelectedKeyboardView;
}
- (instancetype)init {
    self = [super initWithNode:[[ASDisplayNode alloc] init]];
    if (self) {
        _viewModel                                  = [[ContactViewModel alloc] initWithBus: [[ContactBus alloc] initWithAdapter:[[ContactAdapter alloc] init]]];
        _searchNode                                 = [[SearchNode alloc] initWithHeight:SEARCH_BAR_HEIGHT];
        _contentNode                                = [[ASDisplayNode alloc] init];
        _contactSelectedView                        = [[HorizontalListNode alloc] init];
        _contactSelectedKeyboardView                = [[HorizontalListNode alloc] init];
        _isShowSelected                             = NO;
        _contactSelectedView.layer.shadowColor      = UIColor.grayColor.CGColor;
        _contactSelectedView.layer.shadowOpacity    = 1;
        _contactSelectedView.layer.shadowOffset     = CGSizeMake(1, 0);
        
        _contactSelectedView.collectionNode.delegate            = self;
        _contactSelectedView.collectionNode.dataSource          = self;
        _contactSelectedKeyboardView.collectionNode.delegate    = self;
        _contactSelectedKeyboardView.collectionNode.dataSource  = self;
        
        [self showSelectedContactsArea:NO];
        [_contactSelectedKeyboardView setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 80)];
        
        _searchNode.bar.inputAccessoryView = _contactSelectedKeyboardView.view;
        
        self.node.automaticallyManagesSubnodes  = YES;
        [self layoutSubviews];
        
#if DEBUG_MODE
        _searchNode.backgroundColor             = UIColor.redColor;
        _contentNode.backgroundColor            = UIColor.greenColor;
        _contactSelectedView.backgroundColor    = UIColor.yellowColor;
#endif
        
    }
    return self;
}

#pragma mark - Life circle
- (void)loadView {
    [super loadView];
}

#pragma mark - Layout methods

- (void)layoutContentNode {
    __weak typeof(self) weakSelf = self;
    
    _contentNode.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) child:[strongSelf->_contentViewController.node styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.flexGrow = 10;
            }]];
        }
        return nil;
    };
    
    [_contentNode layoutIfNeeded];
}

- (void)layoutSubviews {
    __weak typeof(self) weakSelf = self;
    
    self.node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            ASDisplayNode * contentNode = strongSelf->_contentNode;
            ASLayoutSpec * searchBarLayout = [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(UIApplication.sharedApplication.windows[0].safeAreaInsets.top, 0, 0, 0)
                                                                                    child:strongSelf->_searchNode];
            
            ASDisplayNode * contentNodeLayout = [contentNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.flexGrow = 10;
                style.flexShrink = 10;
            }];
            
            ASDisplayNode * selectedLayout = [strongSelf->_contactSelectedView styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    style.flexShrink = 1;
                    style.preferredSize = CGSizeMake(strongSelf.node.calculatedSize.width, 80 + self.view.safeAreaInsets.bottom);
                }
            }];
            
            return [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                           spacing:0
                                                    justifyContent:ASStackLayoutJustifyContentStart
                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                          children:
                    strongSelf->_isShowSelected ?
                    @[searchBarLayout, contentNodeLayout, selectedLayout ] :
                    @[searchBarLayout, contentNodeLayout]
                    ];
        }
        NSAssert(NO, @"StrongSelf referrence had dealocated");
        return nil;
    };
}

#pragma mark - ASCollectionDatasource methods
- (NSInteger)numberOfSectionsInCollectionNode:(ASCollectionNode *)collectionNode {
    return 1;
}

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section {
    return [_viewModel numberOfSelectedContacts];
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    ContactViewEntity * contact = [_viewModel selectedContactAtIndex:indexPath.item];
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode * {
        ContactCollectionCellNode *  cellNode = [[ContactCollectionCellNode alloc] initWithContact:contact];
        cellNode.delegate = weakSelf;
        return cellNode;
    };
    return ASCellNodeBlock;
}

- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(55, 55));
}

#pragma mark - Subclass methods
- (id<ContactViewModelProtocol>)viewModel {
    return _viewModel;
}

- (UISearchBar *)searchBar {
    return _searchNode.bar;
}

- (void)resetAllData {
    
}

- (void)showSelectedContactsArea:(BOOL)isShow {
    _isShowSelected = isShow;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->_contactSelectedView.alpha = isShow ? 1 : 0;
            strongSelf->_contactSelectedKeyboardView.alpha = isShow ? 1 : 0;
        }
    } completion:^(BOOL finished) {
        [weakSelf.node setNeedsLayout];
    }];
}

- (void)addSelectedContact:(NSIndexPath *) indexPath {
    [_contactSelectedView.collectionNode insertItemsAtIndexPaths:@[indexPath]];
    [_contactSelectedKeyboardView.collectionNode insertItemsAtIndexPaths:@[indexPath]];
    
    [_contactSelectedView.collectionNode scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    [_contactSelectedKeyboardView.collectionNode scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

- (void)removeSelectedContact:(NSIndexPath *) indexPath {
    [_contactSelectedView.collectionNode deleteItemsAtIndexPaths:@[indexPath]];
    [_contactSelectedKeyboardView.collectionNode deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)loadContact {
    __weak typeof(self) weakSelf = self;
    [_viewModel loadContacts:^(BOOL isSuccess, NSError *error, NSUInteger numberOfContacts) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (isSuccess) {
                ContactTableNodeController * table = [[ContactTableNodeController alloc] initWithViewModel:strongSelf->_viewModel];
                table.keyboardAppearanceDelegate = strongSelf;
                strongSelf->_contentViewController = table;
            } else {
                ResponseInformationViewController * resVc = nil;
                if (numberOfContacts == 0) {
                    resVc = [strongSelf loadResponseInforView:ResponseViewTypeEmptyContact];
                } else {
                    resVc = [strongSelf loadResponseInforView:ResponseViewTypeFailLoadingContact];
                }
                resVc.keyboardAppearanceDelegate = strongSelf;
                
                ASDisplayNode * node = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
                    return resVc.view;
                }];
                
                strongSelf->_contentViewController = [[ASViewController alloc] initWithNode: node];
            }
            [strongSelf addChildViewController:strongSelf->_contentViewController];
            [strongSelf->_contentNode addSubnode:strongSelf->_contentViewController.node];
            [strongSelf layoutContentNode];
            [strongSelf->_contentNode setNeedsLayout];
        }
    }];
}

@end
