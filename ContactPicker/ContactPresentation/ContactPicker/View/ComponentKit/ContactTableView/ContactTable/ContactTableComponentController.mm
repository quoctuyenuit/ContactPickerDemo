//
//  ContactTableComponentController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "ContactTableComponentController.h"
#import "ContactViewEntity.h"
#import "ContactTableCellComponent.h"
#import "Logging.h"

#define DEBUG_FEATURE_MODE  1
#define AUTO_TAIL_LOADING_NUM_SCREENFULS    2.5

#if DEBUG_FEATURE_MODE
#import "ContactViewModel.h"
#import "ContactBus.h"
#import "ContactAdapter.h"
#endif

@interface ContactTableComponentController () <CKComponentProvider, UICollectionViewDelegateFlowLayout> {
    id<ContactViewModelProtocol>                      _viewModel;
    CKCollectionViewDataSource                      * _dataSource;
    CKComponentFlexibleSizeRangeProvider            * _sizeRangeProvider;
    
}

@end

@implementation ContactTableComponentController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithCollectionViewLayout:layout]) {
        _viewModel          = [[ContactViewModel alloc] initWithBus: [[ContactBus alloc] initWithAdapter:[[ContactAdapter alloc] init]]];
        _sizeRangeProvider  = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    }
    return self;
}

- (instancetype)initWithViewModel:(id<ContactViewModelProtocol>)viewModel {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    
    self = [super initWithCollectionViewLayout:flowLayout];
    
    if (self) {
        _viewModel                  = viewModel;
#if DEBUG_FEATURE_MODE
        _viewModel                  = [[ContactViewModel alloc] initWithBus: [[ContactBus alloc] initWithAdapter:[[ContactAdapter alloc] init]]];
#endif
        
        _sizeRangeProvider          = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
    }
    return self;
}
                                       
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.collectionView.backgroundColor = UIColor.whiteColor;
    self.collectionView.delegate        = self;
    self.collectionView.showsVerticalScrollIndicator    = NO;
    self.collectionView.showsHorizontalScrollIndicator  = NO;
    
    const CKSizeRange sizeRange = [_sizeRangeProvider sizeRangeForBoundingSize:self.collectionView.bounds.size];
    CKDataSourceConfiguration * configuration = [[CKDataSourceConfiguration<ContactViewEntity *, id<NSObject>> alloc]
                                                initWithComponentProviderFunc:ContactComponentProvider
                                                context:nil
                                                sizeRange:sizeRange];
    
    _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                 supplementaryViewDataSource:nil
                                                               configuration:configuration];
    
//    Insert sections
    CKDataSourceChangeset * initalChangeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset]
                                                withInsertedSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 27)]] build];
    
    [_dataSource applyChangeset:initalChangeset mode:CKUpdateModeAsynchronous userInfo:nil];
    
    __weak typeof(self) weakSelf = self;
    [_viewModel loadContacts:^(BOOL isSuccess, NSError * _Nonnull error, NSUInteger numberOfContacts) {
        [weakSelf loadMoreContact];
    }];
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
    ContactViewEntity * contact = [_dataSource modelForItemAtIndexPath:indexPath];
    NSLog(@"Did select %@", contact.fullName);
    [_viewModel selectectContactAtIndex:indexPath];
}

#pragma mark - Helper methods
- (void)loadMoreContact {
    NSLog(@"[ContactTableViewController] load batch");
    __weak typeof(self) weakSelf = self;
    [_viewModel loadBatchOfContacts:^(NSError *error, NSArray<NSIndexPath *> *updatedIndexPaths, NSArray<ContactViewEntity *> * entities) {
        NSLog(@"[ContactTableViewController] load batch respose");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error) {
                [Logging error:error.localizedDescription];
            } else {
                [strongSelf insertCells:updatedIndexPaths forEntities:entities];
            }
        }
    }];
}

- (void)insertCells:(NSArray<NSIndexPath *> *) indexPaths forEntities:(NSArray<ContactViewEntity *> *) entities {
    NSInteger indexCount = indexPaths.count;
    NSInteger entityCount = entities.count;
    if (indexCount != entityCount)
        return;
    
    NSMutableDictionary<NSIndexPath *, ContactViewEntity *> * items = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < indexCount; i++) {
        [items setObject:entities[i] forKey:indexPaths[i]];
    }
    
    CKDataSourceChangeset *changeset = [[[CKDataSourceChangesetBuilder dataSourceChangeset] withInsertedItems:items] build];
    [_dataSource applyChangeset:changeset mode:CKUpdateModeAsynchronous userInfo:nil];
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
        NSLog(@"[ContactTableViewController] load from scroll");
        [self loadMoreContact];
    }
}

+ (CKComponent *)componentForModel:(id<NSObject>)model context:(id<NSObject>)context {
    return nil;
}

@end
