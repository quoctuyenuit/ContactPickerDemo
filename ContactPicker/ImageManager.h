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

@interface ImageManager : NSObject
@property(atomic, readonly) NSCache<NSString *, DataBinding *>  *imageCache;
@property(nonatomic, readonly) NSMutableArray                   *colorsTable;
@property(nonatomic, readonly) NSMutableArray                   *generatedImages;
@property(nonatomic, readonly) id<ContactAdapterProtocol>       contactAdapter;
@property(nonatomic, readonly) dispatch_queue_t                 backgroundQueue;


+ (instancetype) instance;
- (void) updateCache;
- (void) imageForKey:(NSString *) key label:(NSString * _Nullable) label block:(void(^)(ImageObservable * imageObservable)) block;
@end

NS_ASSUME_NONNULL_END
