//
//  ContactTableComponentController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "ContactTableControllerComponentKit.h"
#import "ContactViewEntity.h"
#import "ContactTableCellComponent.h"
#import "Logging.h"
#import "ContactTableHeaderComponentView.h"

#define DEBUG_FEATURE_MODE                  0
#define AUTO_TAIL_LOADING_NUM_SCREENFULS    2.5
#define LOG_MSG_HEADER                      @"ContactTableComponentKit"
#define HEADER_REUSE_IDENTIFIER             @"HeaderReuseIdentifier"

#if DEBUG_FEATURE_MODE
#import "ContactViewModel.h"
#import "ContactBus.h"
#import "ContactAdapter.h"
#endif

@interface ContactTableControllerComponentKit () <CKComponentProvider, UICollectionViewDelegateFlowLayout, CKSupplementaryViewDataSource > {
    id<ContactViewModelProtocol>                      _viewModel;
    CKCollectionViewDataSource                      * _dataSource;
    CKComponentFlexibleSizeRangeProvider            * _sizeRangeProvider;
    UICollectionView                                * _collectionView;
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

- (void)loadView {
    [super loadView];
    
}
                                       
- (void)viewDidLoad {
    [super viewDidLoad];
}

static CKComponent * ContactComponentProvider(ContactViewEntity * contact,id<NSObject> context) {
    return [ContactTableCellComponent newWithContact:contact];
}

- (void)contactSelectedAction:(ContactViewEntity *) contact {
    
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
    [self.keyboardAppearanceDelegate hideKeyboard];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return [_viewModel numberOfContactInSection:section] > 0 ? CGSizeMake(self.view.bounds.size.width, 28) : CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        ContactTableHeaderComponentView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HEADER_REUSE_IDENTIFIER forIndexPath:indexPath];
        headerView.title.text = [[_viewModel getAllSectionNames] objectAtIndex:indexPath.section];
        return headerView;
    }
    return [[UICollectionReusableView alloc] init];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height == 0) {
        return;
    }
    
    CGFloat currentOffSetY = scrollView.contentOffset.y;
    CGFloat contentHeight  = scrollView.contentSize.height;
    CGFloat screenHeight   = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat screenfullsBeforeBottom = (contentHeight - currentOffSetY) / screenHeight;
    if (screenfullsBeforeBottom < AUTO_TAIL_LOADING_NUM_SCREENFULS) {
        NSLog(@"[%@] begin call fetching", LOG_MSG_HEADER);
        [self fetchBatchContactWithBlock:nil];
    }
}

+ (CKComponent *)componentForModel:(id<NSObject>)model context:(id<NSObject>)context {
    return nil;
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
    [self.view addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [_collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [_collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [_collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    _collectionView.backgroundColor = UIColor.whiteColor;
    _collectionView.delegate        = self;
    _collectionView.showsVerticalScrollIndicator    = NO;
    _collectionView.showsHorizontalScrollIndicator  = NO;
    
    [_collectionView registerClass:[ContactTableHeaderComponentView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HEADER_REUSE_IDENTIFIER];

}

- (void)setupDatasets {
    const CKSizeRange sizeRange = [_sizeRangeProvider sizeRangeForBoundingSize:_collectionView.bounds.size];
    CKDataSourceConfiguration * configuration = [[CKDataSourceConfiguration<ContactViewEntity *, id<NSObject>> alloc]
                                                 initWithComponentProviderFunc:ContactComponentProvider
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

- (void)reloadTable {
    [_collectionView reloadData];
}

- (void)insertCells:(NSArray<NSIndexPath *> *)indexPaths forEntities:(NSArray<ContactViewEntity *> *)entities {
    NSInteger indexCount = indexPaths.count;
    NSInteger entityCount = entities.count;
    if (indexCount != entityCount)
        return;
    
    NSLog(@"[%@] begin insert cell from %ld indexpaths", LOG_MSG_HEADER, indexPaths.count);
    NSMutableDictionary<NSIndexPath *, ContactViewEntity *> * items = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < indexCount; i++) {
        [items setObject:entities[i] forKey:indexPaths[i]];
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset] withInsertedItems:items] build];
    [_dataSource applyChangeset:changeset mode:CKUpdateModeAsynchronous userInfo:nil];
}

- (void)removeCells:(NSArray<NSIndexPath *> *)indexPaths {
    NSLog(@"[%@] begin remove cell from %ld indexpaths", LOG_MSG_HEADER, indexPaths.count);
    CKDataSourceChangeset * changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset] withRemovedItems:[[NSSet alloc] initWithArray:indexPaths]] build];
    [_dataSource applyChangeset:changeset mode:CKUpdateModeAsynchronous userInfo:nil];
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    
}
@end
