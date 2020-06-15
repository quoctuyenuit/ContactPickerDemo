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

@protocol ContactViewModelProtocol <NSObject>
@property DataBinding<NSString *> * searchObservable;
@property DataBinding<NSNumber *> * contactBookObservable;

@property DataBinding<NSNumber *> * selectedContactRemoveObservable;
@property DataBinding<NSNumber *> * selectedContactAddedObservable;

@property DataBinding<NSNumber *> * dataSourceHasChanged;
@property DataBinding<NSIndexPath *> * cellNeedRemoveSelectedObservable;

- (void) requestPermission: (void (^)(BOOL granted, NSError * error)) completion;

- (void) loadContacts: (void (^)(BOOL isSuccess, NSError * error, int numberOfContacts)) completion;

- (int) numberOfContactInSection: (NSInteger) section;

- (NSInteger) numberOfSection;

- (ContactViewEntity *) contactAtIndex: (NSIndexPath *) indexPath;

- (void) searchContactWithKeyName: (NSString *) key callBack: (void (^)(void)) handler;

- (void) selectectContactAtIndex: (NSIndexPath *) indexPath;

- (void) removeSelectedContact: (NSString *) identifier;

- (NSString *) titleForHeaderInSection: (NSInteger) section;

- (NSArray *) getAllSectionNames;

@end

#endif /* ContactViewModelProtocol_h */
