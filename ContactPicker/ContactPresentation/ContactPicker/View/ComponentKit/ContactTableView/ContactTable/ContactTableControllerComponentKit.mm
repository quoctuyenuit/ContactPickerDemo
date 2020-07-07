//
//  ContactTableComponentController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_COMPONENTKIT
#import <ComponentKit/ComponentKit.h>
#import "ContactTableControllerComponentKit.h"
#import "ContactViewEntity.h"
#import "ContactTableCellComponent.h"
#import "ContactTableHeaderComponentView.h"
#import "ContactDefine.h"
#import "KeyboardAppearanceDelegate.h"
#import "TableIndexView.h"

#define DEBUG_MODE                          0
#define AUTO_TAIL_LOADING_NUM_SCREENFULS    2.5
#define HEADER_REUSE_IDENTIFIER             @"HeaderReuseIdentifier"

@interface ContactTableControllerComponentKit () <CKComponentProvider, UICollectionViewDelegateFlowLayout, CKSupplementaryViewDataSource ,KeyboardAppearanceDelegate, TableViewIndexDelegate> {
    id<ContactViewModelProtocol>                      _viewModel;
    CKCollectionViewDataSource                      * _dataSource;
    CKComponentFlexibleSizeRangeProvider            * _sizeRangeProvider;
    UICollectionView                                * _collectionView;
    TableIndexView                                  * _tableIndexView;
}

@end

@implementation ContactTableControllerComponentKit
- (instancetype)initWithViewModel:(id<ContactViewModelProtocol>) viewModel {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _viewModel          = viewModel;
        _sizeRangeProvider  = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    }
    return self;
}

#pragma mark - CKComponentProvider methods
+ (CKComponent *)componentForModel:(ContactViewEntity *)contact context:(id<NSObject>)context {
    return [ContactTableCellComponent newWithContact:contact];
}

#pragma mark - UICollectionViewDelegateFlowlayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_dataSource announceWillDisplayCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [_dataSource announceDidEndDisplayingCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_viewModel selectectContactAtIndex:indexPath];
    if (self.keyboardAppearanceDelegate && [self.keyboardAppearanceDelegate respondsToSelector:@selector(hideKeyboard)])
        [self.keyboardAppearanceDelegate hideKeyboard];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return [_viewModel numberOfContactInSection:section] > 0 ? CGSizeMake(self.view.bounds.size.width, 28) : CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        ContactTableHeaderComponentView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HEADER_REUSE_IDENTIFIER forIndexPath:indexPath];
        headerView.title.text = [[_viewModel sectionIndexTitles] objectAtIndex:indexPath.section];
        return headerView;
    }
    return [[UICollectionReusableView alloc] init];
}

#pragma mark - Subclass methods
- (id<ContactViewModelProtocol>)viewModel {
    return _viewModel;
}

- (void)setupBaseViews {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    _tableIndexView = [[TableIndexView alloc] initWithTitlesIndex:[_viewModel sectionIndexTitles]];
    
    
    [self.view addSubview:_collectionView];
    [self.view addSubview: _tableIndexView];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableIndexView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active      = YES;
    [_collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active  = YES;
    [_collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active    = YES;
    [_collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [_tableIndexView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active      = YES;
    [_tableIndexView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active  = YES;
    [_tableIndexView.widthAnchor constraintEqualToConstant: 15].active                  = YES;
    [_tableIndexView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    _tableIndexView.delegate = self;
    
    _collectionView.backgroundColor = UIColor.whiteColor;
    _collectionView.delegate        = self;
    _collectionView.showsVerticalScrollIndicator    = NO;
    _collectionView.showsHorizontalScrollIndicator  = NO;
    
    [_collectionView registerClass:[ContactTableHeaderComponentView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_REUSE_IDENTIFIER];
    
#if DEBUG_MODE
    _collectionView.backgroundColor = UIColor.greenColor;
#endif

}

- (void)setupDatasets {
    const CKSizeRange sizeRange = [_sizeRangeProvider sizeRangeForBoundingSize:_collectionView.bounds.size];
    CKDataSourceConfiguration * configuration = [[CKDataSourceConfiguration<ContactViewEntity *, id<NSObject>> alloc]
                                                 initWithComponentProvider:[self class]
                                                 context:nil
                                                 sizeRange:sizeRange];
    
    _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:_collectionView
                                                 supplementaryViewDataSource:self
                                                               configuration:configuration];
    
    //    Insert sections
    CKDataSourceChangeset * initalChangeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                                withInsertedSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 27)]] build];
    
    [_dataSource applyChangeset:initalChangeset mode:CKUpdateModeAsynchronous userInfo:nil];
}

- (void)showErrorView:(ResponseViewType)type {
    ResponseInformationView * resView = [[ResponseInformationView alloc] initWithType:type];
    resView.keyboardAppearanceDelegate = self;
    [_collectionView removeFromSuperview];
    [self.view addSubview:resView];
    resView.translatesAutoresizingMaskIntoConstraints = NO;
    [resView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active          =  YES;
    [resView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active        =  YES;
    [resView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active      =  YES;
    [resView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active    =  YES;
}

- (void)reloadTable {
    [_collectionView reloadData];
}

- (void)insertContactFromIndexPath:(NSArray<NSIndexPath *> *)indexPaths forEntities:(NSArray<ContactViewEntity *> *)entities {
    NSInteger indexCount = indexPaths.count;
    NSInteger entityCount = entities.count;
    if (indexCount != entityCount)
        return;
    
    DebugLog(@"[%@] begin insert cell from %ld indexpaths", LOG_MSG_HEADER, indexPaths.count);
    NSMutableDictionary<NSIndexPath *, ContactViewEntity *> * items = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < indexCount; i++) {
        [items setObject:entities[i] forKey:indexPaths[i]];
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset] withInsertedItems:items] build];
    [_dataSource applyChangeset:changeset mode:CKUpdateModeAsynchronous userInfo:nil];
}

- (void)removeCells:(NSArray<NSIndexPath *> *)indexPaths {
    DebugLog(@"[%@] begin remove cell from %ld indexpaths", LOG_MSG_HEADER, indexPaths.count);
    CKDataSourceChangeset * changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset] withRemovedItems:[[NSSet alloc] initWithArray:indexPaths]] build];
    [_dataSource applyChangeset:changeset mode:CKUpdateModeAsynchronous userInfo:nil];
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    
}

- (void)updateCells:(NSMutableDictionary<NSIndexPath *,ContactViewEntity *> *)indexsNeedUpdate {
    [_collectionView reloadData];
}

- (void) hideKeyboard {
    if (self.keyboardAppearanceDelegate && [self.keyboardAppearanceDelegate respondsToSelector:@selector(hideKeyboard)])
        [self.keyboardAppearanceDelegate hideKeyboard];
}


- (void)tableIndexView:(nonnull TableIndexView *)indexView didSelectAt:(NSInteger)index {
    while (index < [_viewModel numberOfSection] && [_viewModel numberOfContactInSection:index] == 0) {
        index++;
    }
    
    if (index < [_viewModel numberOfSection]) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:index];
        UICollectionViewLayoutAttributes * attributes = [_collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        [_collectionView setContentOffset:CGPointMake(0, attributes.frame.origin.y - _collectionView.contentInset.top) animated:YES];
    }
}
@end
#endif
