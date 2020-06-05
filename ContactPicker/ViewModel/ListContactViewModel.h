//
//  ListContactViewModel.h
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBinding.h"
#import "ContactViewModel.h"
#import "ContactBusProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ViewHandler)(BOOL, int);

@interface ListContactViewModel : NSObject {
    NSMutableArray<ContactViewModel *> *_listContactOnView;
    NSMutableArray<ContactViewModel *> *_listContact;
    id<ContactBusProtocol> _contactBus;
}

@property DataBinding<NSString *> * search;
@property DataBinding<NSArray *> * updateContacts;
@property NSMutableArray<ContactViewModel *> * listContact;
@property NSMutableArray<ContactViewModel *> * listContactOnView;
//@property DataBinding<NSNumber*>* numberOfContact;

- (id)initWithBus: (id<ContactBusProtocol>) bus;

- (void)loadContacts: (ViewHandler) completion;

- (void)loadBatch: (ViewHandler) completion;

- (int)getNumberOfContacts;

- (ContactViewModel*)getContactAt: (int) index;

- (void) searchContactWithKeyName: (NSString *) key completion: (void (^)(BOOL)) handler;

- (void) refreshListContact;
@end

NS_ASSUME_NONNULL_END
