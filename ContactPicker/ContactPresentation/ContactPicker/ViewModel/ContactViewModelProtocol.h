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
typedef void(^ViewModelResponseListBlock)(NSArray<ContactViewEntity *> * _Nullable contacts, NSArray<NSIndexPath *> * _Nullable indexPaths, NSError * _Nullable error);

@protocol ContactViewModelProtocol <NSObject>
@property DataBinding<NSString *>                   * searchObservable;
@property DataBinding<NSNumber *>                   * contactBookObservable;

@property DataBinding<NSNumber *>                   * selectedContactRemoveObservable;
@property DataBinding<NSNumber *>                   * selectedContactAddedObservable;

@property DataBinding<NSArray<NSIndexPath *> *>     * dataSourceNeedReloadObservable;
@property DataBinding<NSIndexPath *>                * cellNeedRemoveSelectedObservable;

#pragma mark - ContactTableDataSource methods
- (NSInteger) numberOfSection;

- (int) numberOfContactInSection: (NSInteger) section;

- (ContactViewEntity *) contactAtIndex: (NSIndexPath *) indexPath;

- (NSString *) titleForHeaderInSection: (NSInteger) section;

- (NSArray *) getAllSectionNames;

#pragma mark - Selected Contact CollectionDataSource methods
- (NSInteger)numberOfSelectedContacts;

- (ContactViewEntity *) selectedContactAtIndex: (NSInteger) index;

#pragma mark - Feature methods
- (void) requestPermission: (void (^)(BOOL granted, NSError * error)) completion;

- (void) loadContactsWithBlock: (ViewModelResponseListBlock) block;

- (void) searchContactWithKeyName: (NSString *) key block:(ViewModelResponseListBlock) block;

- (void) selectectContactAtIndex: (NSIndexPath *) indexPath;

- (void) removeSelectedContact: (NSString *) identifier;

- (NSIndexPath * _Nullable)firstContactOnView;
@end

NS_ASSUME_NONNULL_END

#endif /* ContactViewModelProtocol_h */
