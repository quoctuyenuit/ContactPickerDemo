//
//  ImageCacher.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactAdapterProtocol.h"
#import "DataBinding.h"
#import "AvatarObj.h"

NS_ASSUME_NONNULL_BEGIN

typedef DataBinding<AvatarObj *> ImageObservable;
typedef void(^ResponseImageBlock)(AvatarObj *image, NSString *identifier);

@interface ImageManager : NSObject
@property(nonatomic, readonly) NSCache<NSString *, AvatarObj *>  *imageCache;
@property(nonatomic, readonly) NSMutableArray                   *generatedImages;
@property(nonatomic, readonly) id<ContactAdapterProtocol>       contactAdapter;
@property(nonatomic, readonly) dispatch_queue_t                 backgroundQueue;
@property(nonatomic, readonly) BOOL                             isLoaded;

@property(nonatomic, readonly) NSMutableDictionary<NSString *, NSMutableArray<ResponseImageBlock> *> *requestedBlock;


+ (instancetype) instance;
- (void) updateCacheWithComplete:(void(^_Nullable)(void))block;
- (void) imageForKey:(NSString *) key label:(NSString * _Nullable) label block:(ResponseImageBlock) block;
@end

NS_ASSUME_NONNULL_END
