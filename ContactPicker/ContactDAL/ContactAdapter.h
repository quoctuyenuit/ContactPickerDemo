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
@property(atomic, readonly) dispatch_queue_t    loadContactQueue;
@property(atomic, readonly) dispatch_queue_t    responseLoadContactQueue;
@property(atomic, readonly) dispatch_queue_t    loadImageQueue;
@property(atomic, readonly) dispatch_queue_t    responseLoadImageQueue;

@property(atomic, readonly) BOOL                loadInProcessing;
@property(atomic, readonly) BOOL                loadImageInProcessing;
@property(nonatomic, readonly) NSArray          *fetchRequest;

@property(atomic, readonly) NSMutableArray<AdapterResponseListBlock>   *loadContactRequest;
@property(atomic, readonly) NSMutableArray<AdapterResponseListImageBlock>   *loadContactImageRequest;

- (id)init;
@end

NS_ASSUME_NONNULL_END
