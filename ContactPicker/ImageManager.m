//
//  ImageCacher.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ImageManager.h"
#import "Utilities.h"
#import "ContactDefine.h"
#import "ContactGlobalConfigure.h"
#import "ImageRequestHandler.h"

#define DEBUG_MODE          0
#define CACHE_SIZE          10 * 1024 * 1024

@interface ImageManager ()

@property(nonatomic) NSCache<NSString *, AvatarObj *> *     imageCache;
@property(nonatomic) NSMutableArray<NSString *> *           keys;
@property(nonatomic) NSMutableArray *                       generatedImages;
@property(nonatomic) NSArray *                              gradientColors;
@property(nonatomic) dispatch_queue_t                       internalSerialQueue;
@property(nonatomic) dispatch_queue_t                       requestQueue;

@property(nonatomic) NSMutableDictionary<NSString *, ImageRequestHandler *> * requestHandlers;


- (instancetype)_initWithSize:(NSInteger) size;
- (NSArray *)_getGradientColors;
- (UIImage *)_randomImage;
- (UIImage *)_createGradientImageWithSize:(CGSize) size colors:(NSArray *) colors;
- (AvatarObj *)_generateImage;
@end

@implementation ImageManager

+ (instancetype)instance {
    static dispatch_once_t once;
    static ImageManager *sharedInstance;

    dispatch_once(&once, ^
    {
        sharedInstance = [[ImageManager alloc] _initWithSize:CACHE_SIZE];
    });
    return sharedInstance;
}

#pragma mark - Private methods
- (instancetype)_initWithSize:(NSInteger) size {
    _imageCache                 = [[NSCache alloc] init];
    _gradientColors             = [NSArray arrayWithArray: [self _getGradientColors]];
    _requestHandlers            = [[NSMutableDictionary alloc] init];
    _internalSerialQueue            = dispatch_queue_create("ImageManage queue",
                                                        dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                                QOS_CLASS_BACKGROUND, 0));
    _requestQueue               = dispatch_queue_create("ImageManage queue",
                                                        dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                                                QOS_CLASS_BACKGROUND, 0));
    [_imageCache setTotalCostLimit:size];
    
    return self;
}

- (NSArray *)_getGradientColors {
    
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:@[(id)[UIColor colorFromHex:@"#7bd5f5"].CGColor, (id)[UIColor colorFromHex:@"#787ff6"].CGColor]];
    [colors addObject:@[(id)[UIColor colorFromHex:@"#787ff6"].CGColor, (id)[UIColor colorFromHex:@"#4adede"].CGColor]];
    [colors addObject:@[(id)[UIColor colorFromHex:@"#4adede"].CGColor, (id)[UIColor colorFromHex:@"#1ca7ec"].CGColor]];
    [colors addObject:@[(id)[UIColor colorFromHex:@"#667db6"].CGColor, (id)[UIColor colorFromHex:@"#0082c8"].CGColor, (id)[UIColor colorFromHex:@"#0082c8"].CGColor, (id)[UIColor colorFromHex:@"#667db6"].CGColor]];
    [colors addObject:@[(id)[UIColor colorFromHex:@"#ff9190"].CGColor, (id)[UIColor colorFromHex:@"#fdc094"].CGColor]];
    [colors addObject:@[(id)[UIColor colorFromHex:@"#659999"].CGColor, (id)[UIColor colorFromHex:@"#f4791f"].CGColor]];
    [colors addObject:@[(id)[UIColor colorFromHex:@"#ff9a9e"].CGColor, (id)[UIColor colorFromHex:@"#fecfef"].CGColor]];
    [colors addObject:@[(id)[UIColor colorFromHex:@"#c79081"].CGColor, (id)[UIColor colorFromHex:@"#dfa579"].CGColor]];

    return colors;
}

- (UIImage *)_randomImage {
    NSUInteger index = arc4random_uniform((uint32_t)_gradientColors.count);
    if (index >= _generatedImages.count) {
        NSArray * color = [_gradientColors objectAtIndex:index];
        UIImage * image = [self _createGradientImageWithSize:[ContactGlobalConfigure globalConfig].avatarSize
                                                      colors:color];
        [_generatedImages addObject: image];
        return image;
    }
    return _generatedImages[index];
}

- (UIImage *)_createGradientImageWithSize:(CGSize)size colors:(NSArray *) colors {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, size.width, size.height);
    layer.colors = colors;

    UIGraphicsBeginImageContext(layer.bounds.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (AvatarObj *)_generateImage {
    UIImage * image = [self _randomImage];
    return [[AvatarObj alloc] initWithImage:image isGenerated:YES];
}

- (void)_excuteRequestWithHandler:(ImageRequestHandler *)handler forBlock:(ResponseImageBlock)block {
    [handler requestWithBlock:block completion:^(NSString * _Nonnull key, AvatarObj * _Nullable img, NSError * _Nullable error) {
        if (!error) {
            img.isLoaded = YES;
            [self.imageCache setObject:img forKey:key];
        } else {
            AvatarObj *imageInCache = [self.imageCache objectForKey:key];
            imageInCache.isLoaded = YES;
        }
    }];
}

- (void)_requestImageFromResourceWithBlock:(ResponseImageBlock)block forKey:(NSString *)key {
//    Excute immediately if handler already exists
    ImageRequestHandler * handler = [self.requestHandlers objectForKey:key];
    if (handler) {
        [self _excuteRequestWithHandler:handler forBlock:block];
        return;
    }
    
//    Create handler for key in serial queue to make sure one key just create one handler.
    weak_self
    dispatch_async(_requestQueue, ^{
        ImageRequestHandler * handler = [weakSelf.requestHandlers objectForKey:key];
        if (!handler) {
            handler = [[ImageRequestHandler alloc] initWithKey:key];
            [weakSelf.requestHandlers setObject:handler forKey:key];
        }
        
        [self _excuteRequestWithHandler:handler forBlock:block];
    });
}

#pragma mark - Public methods
- (void)updateCacheWithCompletion:(void (^)(void))block {
    weak_self
    dispatch_async(_internalSerialQueue, ^{
        for (NSString * key in weakSelf.keys) {
            AvatarObj *imageObject = [weakSelf.imageCache objectForKey:key];
            imageObject.isLoaded = NO;
        }
        if (block) {
            block();
        }
    });
}

- (void)imageForKey:(NSString *)key
              block:(ResponseImageBlock)block {
    NSAssert(block, @"block is nil");
    NSAssert(key, @"key is nil");
    if (!block || !key)
        return;
    /** Allow to get image immediately if image in cache.
     * if have multiple request in once time, we can adapt all one in same time.
     */
    AvatarObj *img = [_imageCache objectForKey:key];
    if (!img) {
        img = [self _generateImage];
    }
    
    block(img, key);
    if (img.isLoaded) {
        return;
    }
    [self _requestImageFromResourceWithBlock:block forKey:key];
    /** If not, let generate gradient image and push it to cache,
     * the process will take in serial queue to make sure one identifier is pushed image once time.
     */
    weak_self
    dispatch_async(_internalSerialQueue, ^{
        strong_self
        if (strongSelf) {
            AvatarObj *imageInCache = [strongSelf.imageCache objectForKey:key];
            if (!imageInCache) {
                [strongSelf->_imageCache setObject:img forKey:key];
                [strongSelf->_keys addObject:key];
            }
            block(img, key);
        }
    });
}
@end
