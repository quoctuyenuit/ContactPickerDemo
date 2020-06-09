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
    id<ContactBusProtocol> _contactBus;
}

@property(atomic) NSMutableArray<ContactViewEntity *> * listContacts;

- (id)initWithBus: (id<ContactBusProtocol>) bus;
@end

NS_ASSUME_NONNULL_END
