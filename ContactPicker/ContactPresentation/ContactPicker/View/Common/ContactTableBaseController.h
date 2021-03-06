//
//  ContactTableBaseController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/20/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "KeyboardAppearanceDelegate.h"
#import "ContactViewModelProtocol.h"
#import "ResponseInformationView.h"

#define AUTO_TAIL_LOADING_NUM_SCREENFULS    2.5

NS_ASSUME_NONNULL_BEGIN


@interface ContactTableBaseController : ASViewController<KeyboardAppearanceProtocol>
@property(nonatomic, readwrite) id<ContactViewModelProtocol>      viewModel;
@property(nonatomic, readwrite) BOOL                              contactHadLoad;

- (void)setupBaseViews;
- (void)setupDatasets;
- (void)showErrorView:(ResponseViewType) type;
- (void)reloadTable;
- (void)reloadTableWithDeletedIndexes:(NSArray<NSIndexPath *> *)deletedIndexPaths
                         addedIndexes:(NSArray<NSIndexPath *> *)addedIndexPaths;
- (void)removeCells:(NSArray<NSIndexPath *> *) indexPaths;
- (void)contactHadRemoved:(NSIndexPath *) indexPath;
@end

NS_ASSUME_NONNULL_END
