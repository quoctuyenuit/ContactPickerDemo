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
#import "ContactViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN



@interface ContactViewModel : NSObject<ContactViewModelProtocol> {
    NSMutableArray<ContactViewEntity *> *_listSelectedContacts;
    id<ContactBusProtocol> _contactBus;
    NSMutableArray<NSString *> *_listSectionKeys;
}

@property(atomic) NSMutableDictionary<NSString *, NSMutableArray<ContactViewEntity *> *> * contactsBackup;
@property(atomic) NSMutableDictionary<NSString *, NSMutableArray<ContactViewEntity *> *> * contactsOnView;
@property(nonatomic) id<ContactBusProtocol> contactBus;

- (id)initWithBus: (id<ContactBusProtocol>) bus;

- (ContactViewEntity *) contactWithIdentifier: (NSString *) identifier name: (NSString *) name;

- (ContactViewEntity * _Nullable) contactWithIdentifier: (NSString *) identifier;

- (BOOL) isContainContact: (ContactViewEntity *) contact;

- (NSIndexPath *) indexOfContact: (ContactViewEntity *) contact;
@end

NS_ASSUME_NONNULL_END
