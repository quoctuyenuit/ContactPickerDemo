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
#import "ContactBusinessLayerProtocol.h"
#import "ContactViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN



@interface ContactViewModel : NSObject<ContactViewModelProtocol>

@property(nonatomic, readonly) id<ContactBusinessLayerProtocol>            contactBus;
@property(nonatomic, readonly) NSMutableArray<NSString *>           *listSectionKeys;
@property(nonatomic, readonly) NSMutableArray<ContactViewEntity *>  *listSelectedContacts;

@property(atomic, readonly) NSMutableDictionary<NSString *, NSMutableArray<ContactViewEntity *> *> *contactsOnView;

@property(nonatomic, readonly) dispatch_queue_t     backgroundConcurrentQueue;
@property(nonatomic, readonly) dispatch_queue_t     backgroundSerialQueue;

- (id)initWithBus: (id<ContactBusinessLayerProtocol>) bus;

- (ContactViewEntity *) contactOfIdentifier: (NSString *) identifier name: (NSString *) name;

- (ContactViewEntity * _Nullable) contactOfIdentifier: (NSString *) identifier;

- (BOOL) isContainContact: (ContactViewEntity *) contact;

- (NSIndexPath *) indexOfContact: (ContactViewEntity *) contact;
@end

NS_ASSUME_NONNULL_END
