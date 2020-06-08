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

- (void) requestPermission: (void (^)(BOOL)) completion;

- (void)loadContacts: (void (^)(BOOL isSuccess, int numberOfContacts)) completion;

- (void)loadBatch: (void (^)(BOOL isSuccess, int numberOfContacts)) completion;

- (int)getNumberOfContacts;

- (ContactViewEntity *)getContactAt: (int) index;

- (void) searchContactWithKeyName: (NSString *) key completion: (void (^)(BOOL)) handler;

@end

#endif /* ContactViewModelProtocol_h */
