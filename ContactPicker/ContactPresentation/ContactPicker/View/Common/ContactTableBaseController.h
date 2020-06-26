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

#define AUTO_TAIL_LOADING_NUM_SCREENFULS    2.5

#define DEBUG_MEM_ENABLE                    0
#if DEBUG_MEM_ENABLE
#define NUMBER_OF_BATCH                     30
#endif

NS_ASSUME_NONNULL_BEGIN


@interface ContactTableBaseController : ASViewController<KeyboardAppearanceProtocol>
@property(nonatomic, readwrite) id<ContactViewModelProtocol>      viewModel;
@property(nonatomic, readwrite) BOOL                              contactHadLoad;

- (void)setupBaseViews;
- (void)setupDatasets;
- (void)reloadTable;
- (void)insertCells:(NSArray<NSIndexPath *> *) indexPaths forEntities:(NSArray<ContactViewEntity *> *) entities;
- (void)removeCells:(NSArray<NSIndexPath *> *) indexPaths;
- (void)fetchBatchContactWithBlock:(void(^_Nullable)(void)) block;
- (void)contactHadRemoved:(NSIndexPath *) indexPath;
@end

NS_ASSUME_NONNULL_END
