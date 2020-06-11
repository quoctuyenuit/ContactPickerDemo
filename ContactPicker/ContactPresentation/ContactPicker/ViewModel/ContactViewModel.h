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
    NSMutableArray<ContactViewEntity *> *_listContacts;
    NSMutableArray<ContactViewEntity *> *_listSelectedContacts;
    id<ContactBusProtocol> _contactBus;
}

@property(atomic) NSDictionary<NSString *, NSMutableArray<ContactViewEntity *> *> * contacts;

@property(atomic) NSMutableArray<ContactViewEntity *> * listContacts;
@property(atomic) NSMutableArray<ContactViewEntity *> * listSelectedContacts;
@property(nonatomic) id<ContactBusProtocol> contactBus;

- (id)initWithBus: (id<ContactBusProtocol>) bus;
@end

NS_ASSUME_NONNULL_END
