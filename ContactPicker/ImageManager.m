//
//  ImageCacher.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/1/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ImageManager.h"
#import "Utilities.h"
#import "ContactAdapter.h"
#import "ContactDefine.h"
#import "ContactGlobalConfigure.h"

#define DEBUG_MODE          0
#define CACHE_SIZE          10 * 1024 * 1024
#define COLOR_SOURCE_FILE   @"gradient_colors"
#define JSON_COLOR_KEY      @"colors"

@interface ImageManager ()
- (instancetype)_initWithSize:(NSInteger) size;
- (void)_createColorsTable;
- (NSDictionary *)_JSONFromFile:(NSString *)filePath;
- (UIImage *)_randomImage;
- (UIImage *)_createGradientImageWithSize:(CGSize) size colors:(NSArray *) colors;
- (AvatarObj *)_generateImageFromLabel:(NSString *) label forKey:(NSString *)key;
@end

@implementation ImageManager

+ (instancetype)instance {
    static dispatch_once_t once;
    static ImageManager *sharedInstance;

    dispatch_once(&once, ^
    {
        sharedInstance = [[ImageManager alloc] _initWithSize:CACHE_SIZE];
        [sharedInstance updateCacheWithComplete:nil];
    });
    return sharedInstance;
}

#pragma mark - Private methods
- (instancetype)_initWithSize:(NSInteger) size {
    _imageCache                 = [[NSCache alloc] init];
    _contactAdapter             = [[ContactAdapter alloc] init];
    _generatedImages            = [[NSMutableArray alloc] init];
    _isLoaded                   = NO;
    
    _requestedBlock             = [[NSMutableDictionary alloc] init];
    
    _backgroundQueue            = dispatch_queue_create("ImageManage queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    
    [_imageCache setTotalCostLimit:size];
    [self _createColorsTable];
    return self;
}

- (void)_createColorsTable {
    NSDictionary * dict = [self _JSONFromFile:COLOR_SOURCE_FILE];
    NSAssert([dict.allKeys containsObject:JSON_COLOR_KEY], @"Invalid format of json file");
    NSArray * colors = [dict objectForKey:JSON_COLOR_KEY];
    
    for (NSArray * gradientColor in colors) {
        NSArray * color = [gradientColor map:^id _Nonnull(NSString * _Nonnull obj) {
            return (id)[UIColor colorFromHex:obj].CGColor;
        }];
        
        [_generatedImages addObject: [self _createGradientImageWithSize:[ContactGlobalConfigure globalConfig].avatarSize
                                                                 colors:color]];
    }
}

- (UIImage *)_randomImage {
    NSUInteger index = arc4random_uniform((uint32_t)_generatedImages.count);
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

- (NSDictionary *)_JSONFromFile:(NSString *)filePath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:filePath ofType:@"json"];
    NSAssert(path != nil, @"File path: %@ \nnot exists!", filePath);
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (AvatarObj *)_generateImageFromLabel:(NSString *) label forKey:(NSString *)key {
    NSAssert(key, @"key is nil");
    UIImage * image = [self _randomImage];
    return [[AvatarObj alloc] initWithImage:image label:label isGenerated:YES];
}

#pragma mark - Public methods
- (void)updateCacheWithComplete:(void (^)(void))block {
    weak_self
    [_contactAdapter loadContactImagesWithBlock:^(NSDictionary<NSString *,NSData *> *images, NSError *error) {
        dispatch_async(weakSelf.backgroundQueue, ^{
            strong_self
            if (strongSelf) {
                for (NSString * key in images.allKeys) {
                    NSData * imageData = [images objectForKey:key];
                    UIImage * image = [UIImage imageWithImage:[UIImage imageWithData:imageData]
                                             scaledToFillSize:[ContactGlobalConfigure globalConfig].avatarSize];
                    
                    AvatarObj * imgObj = [[AvatarObj alloc] initWithImage:image label:@"" isGenerated:NO];
                    [strongSelf.imageCache setObject:imgObj forKey:key];
                    
                    NSMutableArray *queue = [strongSelf->_requestedBlock objectForKey:key];
                    for (ResponseImageBlock block in queue) {
                        block(imgObj, key);
                    }
                }
                strongSelf->_isLoaded = YES;
            }
            if (block) {
                block();
            }
        });
    }];
}

- (void)imageForKey:(NSString *)key
              label:(NSString *)label
              block:(ResponseImageBlock)block {
    NSAssert(block, @"block is nil");
    NSAssert(key, @"key is nil");
    /** Allow to get image immediately if image in cache.
     * if have multiple request in once time, we can adapt all one in same time.
     */
    AvatarObj *img = [_imageCache objectForKey:key];
    if (!img) {
        img = [self _generateImageFromLabel:label forKey:key];
    }
    block(img, key);
    
    if (_isLoaded) {
        return;
    }
    
    /** If not, let generate gradient image and push it to cache,
     * the process will take in serial queue to make sure one identifier is pushed image once time.
     */
    weak_self
    dispatch_async(_backgroundQueue, ^{
        strong_self
        if (strongSelf) {
            AvatarObj *imgInCache = [strongSelf.imageCache objectForKey:key];
            if (!imgInCache) {
                [strongSelf->_imageCache setObject:img forKey:key];
                
                NSMutableArray *queue = [strongSelf->_requestedBlock objectForKey:key];
                if (!queue) {
                    queue = [NSMutableArray array];
                    [strongSelf->_requestedBlock setObject:queue forKey:key];
                }
                [queue addObject:block];
            } else {
                block(imgInCache, key);
            }
        }
    });
}
@end
