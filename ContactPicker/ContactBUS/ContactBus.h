//
//  ContactBus.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactBusProtocol.h"
#import "ContactAdapterProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactBus : NSObject<ContactBusProtocol> {
    id<ContactAdapterProtocol> _contactAdapter;
    
}

- (id) initWithAdapter: (id<ContactAdapterProtocol>) adapter;
@end

NS_ASSUME_NONNULL_END
