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
+ (instancetype) instance;
- (void) updateCacheWithCompletion:(void(^)(void))block;
- (void) imageForKey:(NSString *) key block:(ResponseImageBlock) block;
@end

NS_ASSUME_NONNULL_END
