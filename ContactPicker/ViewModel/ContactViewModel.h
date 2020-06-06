//
//  ListContactViewModel.h
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBinding.h"
#import "ContactViewEntity.h"
#import "ContactBusProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ViewHandler)(BOOL, int);

@interface ContactViewModel : NSObject {
    NSMutableArray<ContactViewEntity *> *_listContactOnView;
    NSMutableArray<ContactViewEntity *> *_listContact;
    id<ContactBusProtocol> _contactBus;
}

@property DataBinding<NSString *> * search;
@property DataBinding<NSArray *> * updateContacts;
@property NSMutableArray<ContactViewEntity *> * listContact;
@property NSMutableArray<ContactViewEntity *> * listContactOnView;

- (id)initWithBus: (id<ContactBusProtocol>) bus;

- (void)loadContacts: (ViewHandler) completion;

- (void)loadBatch: (ViewHandler) completion;

- (int)getNumberOfContacts;

- (ContactViewEntity*)getContactAt: (int) index;

- (void) searchContactWithKeyName: (NSString *) key completion: (void (^)(BOOL)) handler;

- (void) refreshListContact;
@end

NS_ASSUME_NONNULL_END
