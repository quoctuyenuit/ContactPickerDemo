//
//  ImageRequestHandler.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvatarObj.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^ResponseImageBlock)(AvatarObj *image, NSString *identifier);
typedef void(^CompletionBlock)(NSString * key, AvatarObj *_Nullable img, NSError *_Nullable error);

@interface ImageRequestHandler : NSObject
@property(nonatomic, readonly) NSString * key;
- (instancetype)initWithKey:(NSString *)key;

- (void)requestWithBlock:(ResponseImageBlock)block completion:(CompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
