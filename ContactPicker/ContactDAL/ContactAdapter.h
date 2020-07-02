//
//  ContactAdapter.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactAdapterProtocol.h"
#import "ImageManager.h"
NS_ASSUME_NONNULL_BEGIN


@interface ContactAdapter : NSObject<ContactAdapterProtocol>
@property(atomic, readonly) dispatch_queue_t    background_queue;
@property(atomic, readonly) dispatch_queue_t    response_queue;
@property(atomic, readonly) BOOL                loadInProcessing;
@property(nonatomic, readonly) NSArray          *fetchRequest;
@property(atomic, readonly) NSMutableArray<AdapterResponseListBlock>   *loadContactRequest;

- (id)init;
@end

NS_ASSUME_NONNULL_END
