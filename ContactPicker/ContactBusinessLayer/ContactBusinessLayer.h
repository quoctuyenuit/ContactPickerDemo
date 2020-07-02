//
//  ContactBus.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusinessLayerProtocol.h"
#import "ContactAdapterProtocol.h"
#import "ContactBusEntity.h"
#import "ContactBusEntityProtocol.h"
#import "ImageManager.h"
#import "DataBinding.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactBusinessLayer : NSObject<BusinessLayerProtocol> {
    id<ContactAdapterProtocol> _contactAdapter; 
}
@property(nonatomic, readonly) id<ContactAdapterProtocol>       contactAdapter;
@property(atomic, readonly) NSMutableArray<ContactBusEntity *>  *contacts;
@property(atomic, readonly) BOOL                                loadInProcessing;
@property(atomic, readonly) BOOL                                searchReady;

@property(nonatomic, readonly) dispatch_queue_t                 backgroundQueue;
@property(nonatomic, readonly) dispatch_queue_t                 loadResponseQueue;
@property(nonatomic, readonly) dispatch_queue_t                 searchQueue;

@property(atomic, readonly) NSMutableArray<BusinessResponseListBlock>   *loadContactRequest;


- (id) initWithAdapter: (id<ContactAdapterProtocol>) adapter;
@end

NS_ASSUME_NONNULL_END
