//
//  ContactViewModelProtocol.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#ifndef ContactViewModelProtocol_h
#define ContactViewModelProtocol_h
#import "ContactViewEntity.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ViewModelResponseListBlock)(NSArray<NSIndexPath *> * _Nullable indexPaths, NSError * _Nullable error);

typedef void(^SearchResponseBlock)(NSArray<ContactViewEntity *> * _Nullable contacts, NSError * _Nullable error);

typedef void(^UpdateTableResponseBlock)(NSArray<NSIndexPath *> *deletedIndexes, NSArray<NSIndexPath *> *addedIndexes);

@protocol ContactViewModelProtocol <NSObject>
@property DataBinding<NSString *>                   * searchObservable;
@property DataBinding<NSNumber *>                   * contactBookObservable;
@property DataBinding<NSIndexPath *>                * selectedContactRemoveObservable;
@property DataBinding<NSIndexPath *>                * selectedContactAddedObservable;
@property DataBinding<NSArray<NSIndexPath *> *>     * removeContactObservable;
@property DataBinding<NSIndexPath *>                * cellNeedRemoveSelectedObservable;

#pragma mark - ContactTableDataSource methods
- (NSInteger) numberOfSection;

- (NSInteger) numberOfContactInSection: (NSInteger) section;

- (ContactViewEntity *) contactAtIndex: (NSIndexPath *) indexPath;

- (NSString *) titleForHeaderInSection: (NSInteger) section;

- (NSArray *) sectionIndexTitles;

#pragma mark - Selected Contact CollectionDataSource methods
- (NSInteger)numberOfSelectedContacts;

- (ContactViewEntity *) selectedContactAtIndex: (NSInteger) index;

#pragma mark - Feature methods
- (void) requestPermissionWithBlock: (void (^)(BOOL granted, NSError * error)) block;

- (void) loadContactsWithBlock: (ViewModelResponseListBlock) block;

- (void) searchContactWithKeyName: (NSString *) key block:(SearchResponseBlock) block;

- (void) selectectContactAtIndex: (NSIndexPath *) indexPath;

- (void) removeSelectedContact: (NSString *) identifier;

- (void) refreshTableWithNewData: (NSArray *) contacts
                      completion:(UpdateTableResponseBlock)block;
@end

NS_ASSUME_NONNULL_END

#endif /* ContactViewModelProtocol_h */
