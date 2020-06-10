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
@property DataBinding<NSString *> * search;
@property DataBinding<NSArray *> * updateContacts;
@property DataBinding<NSNumber *> *numberOfSelectedContacts;

- (void) requestPermission: (void (^)(BOOL granted, NSError * error)) completion;

- (void) loadContacts: (void (^)(BOOL isSuccess, NSError * error, int numberOfContacts)) completion;

- (void) loadBatchOfDetailedContacts: (void (^)(BOOL isSuccess, NSError * error, int numberOfContacts)) completion;

- (int) getNumberOfContacts;

- (ContactViewEntity *) getContactAt: (int) index;

- (void) searchContactWithKeyName: (NSString *) key completion: (void (^)(void)) handler;

- (void) refresh;

- (void) selectectContactAtIndex: (int) index;

@end

#endif /* ContactViewModelProtocol_h */
