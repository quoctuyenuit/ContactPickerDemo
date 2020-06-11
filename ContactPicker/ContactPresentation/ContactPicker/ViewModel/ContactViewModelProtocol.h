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

@property DataBinding<NSNumber *> * numberOfSelectedContactObservable;

@property DataBinding<NSNumber *> * selectedContactRemoveObservable;
@property DataBinding<NSNumber *> * selectedContactAddedObservable;

@property DataBinding<NSNumber *> * numberOfContactObservable;
@property DataBinding<NSNumber *> * indexCellNeedUpdateObservable;


- (void) requestPermission: (void (^)(BOOL granted, NSError * error)) completion;

- (void) loadContacts: (void (^)(BOOL isSuccess, NSError * error, int numberOfContacts)) completion;

- (void) loadBatchOfDetailedContacts: (void (^)(BOOL isSuccess, NSError * error, int numberOfContacts)) completion;

- (int) getNumberOfContacts;

- (ContactViewEntity *) getContactAt: (int) index;

- (void) searchContactWithKeyName: (NSString *) key;

- (void) selectectContactAtIndex: (int) index;

- (void) selectectContactIdentifier: (NSString *) identifier;

- (void) removeSelectedContact: (NSString *) identifier;

@end

#endif /* ContactViewModelProtocol_h */
