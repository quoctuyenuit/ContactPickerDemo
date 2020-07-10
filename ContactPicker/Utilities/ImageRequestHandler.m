//
//  ImageRequestHandler.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ImageRequestHandler.h"
#import "ContactAdapter.h"
#import "ContactDefine.h"
#import "ContactGlobalConfigure.h"
#import "Utilities.h"

@interface ImageRequestHandler ()

@property(nonatomic) id<ContactAdapterProtocol>         contactAdapter;
@property(nonatomic) BOOL                               inProcessing;
@property(nonatomic) dispatch_queue_t                   requestQueue;
@property(nonatomic) dispatch_queue_t                   responseQueue;
@property(nonatomic) NSMutableArray<ResponseImageBlock> *requestBlocks;

@end

@implementation ImageRequestHandler
- (instancetype)initWithKey:(NSString *)key {
    _key = key;
    _contactAdapter = [[ContactAdapter alloc] init];
    _inProcessing   = NO;
    _requestBlocks  = [NSMutableArray array];
    _requestQueue   = dispatch_queue_create("[ImageRequestHandler] Request queue",
                                            dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                    QOS_CLASS_BACKGROUND, 0));
    _responseQueue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    return self;
}

- (void)requestWithBlock:(ResponseImageBlock)block completion:(CompletionBlock)completion {
    if (!block)
        return;
    weak_self
    dispatch_async(_requestQueue, ^{
        [weakSelf.requestBlocks addObject:block];
        if (!weakSelf.inProcessing) {
            weakSelf.inProcessing = YES;
            [weakSelf _excuteRequestWithCompletion:completion];
        }
    });
}

#pragma mark - Internal methods
- (void)_excuteRequestWithCompletion:(CompletionBlock)completion {
    weak_self
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [weakSelf.contactAdapter loadImageWithIdentifier:weakSelf.key block:^(NSData *imageData, NSError *error) {
            if (error) {
                if (completion) {
                    completion(weakSelf.key, nil, error);
                }
            } else {
                UIImage * image = [UIImage imageWithImage:[UIImage imageWithData:imageData]
                                         scaledToFillSize:[ContactGlobalConfigure globalConfig].avatarSize];
                
                AvatarObj * imgObj = [[AvatarObj alloc] initWithImage:image isGenerated:NO];
                dispatch_async(weakSelf.requestQueue, ^{
                    for (ResponseImageBlock block in weakSelf.requestBlocks) {
                        dispatch_async(weakSelf.responseQueue, ^{
                            block(imgObj, weakSelf.key);
                        });
                    }
                    weakSelf.inProcessing = NO;
                });
                if (completion) {
                    completion(weakSelf.key, imgObj, nil);
                }
            }
        } onQueue:nil];
    });
}

@end
