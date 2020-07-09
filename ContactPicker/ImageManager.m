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
- (ImageObservable *)_generateImageFromLabel:(NSString *) label forKey:(NSString *)key;
@end

@implementation ImageManager

+ (instancetype)instance {
    static dispatch_once_t once;
    static ImageManager *sharedInstance;

    dispatch_once(&once, ^
    {
        sharedInstance = [[ImageManager alloc] _initWithSize:CACHE_SIZE];
        [sharedInstance updateCache];
    });
    return sharedInstance;
}

#pragma mark - Private methods
- (instancetype)_initWithSize:(NSInteger) size {
    _imageCache                 = [[NSCache alloc] init];
    _contactAdapter             = [[ContactAdapter alloc] init];
    _generatedImages            = [[NSMutableArray alloc] init];
    
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

- (ImageObservable *)_generateImageFromLabel:(NSString *) label forKey:(NSString *)key {
    NSAssert(key, @"key is nil");
    UIImage * image = [self _randomImage];
    AvatarObj * imgObj = [[AvatarObj alloc] initWithImage:image label:label isGenerated:YES identififer:key];
    ImageObservable *imageObservable = [[ImageObservable alloc] initWithValue:imgObj];
    
    return imageObservable;
}

#pragma mark - Public methods
- (void)updateCache {
    weak_self
    [_contactAdapter loadContactImagesWithBlock:^(NSDictionary<NSString *,NSData *> *images, NSError *error) {
        strong_self
        if (strongSelf) {
            for (NSString * key in images.allKeys) {
                NSData * imageData = [images objectForKey:key];
                UIImage * image = [UIImage imageWithImage:[UIImage imageWithData:imageData]
                                         scaledToFillSize:[ContactGlobalConfigure globalConfig].avatarSize];
                ImageObservable * imageObservable = [strongSelf.imageCache objectForKey:key];
                AvatarObj * imgObj = [[AvatarObj alloc] initWithImage:image label:@"" isGenerated:NO identififer:key];
                if (imageObservable) {
                    imageObservable.value = imgObj;
                } else {
                    imageObservable = [[ImageObservable alloc] initWithValue:imgObj];
                    [strongSelf.imageCache setObject:imageObservable forKey:key];
                }
            }
        }
    }];
}

- (void)imageForKey:(NSString *)key
              label:(NSString *)label
              block:(void (^)(ImageObservable * _Nonnull imageObservable))block {
    NSAssert(block, @"block is nil");
    NSAssert(key, @"key is nil");
    
    /** Allow to get image immediately if image in cache.
     * if have multiple request in once time, we can adapt all one in same time.
     */
    ImageObservable *imageObservable = [_imageCache objectForKey:key];
    if (imageObservable) {
        block(imageObservable);
        return;
    }
    
    /** If not, let generate gradient image and push it to cache,
     * the process will take in serial queue to make sure one identifier is pushed image once time.
     */
    weak_self
    dispatch_async(_backgroundQueue, ^{
        strong_self
        if (strongSelf) {
            ImageObservable *imageObservable = [strongSelf.imageCache objectForKey:key];
            if (!imageObservable) {
                imageObservable = [strongSelf _generateImageFromLabel:label forKey:key];
                [strongSelf->_imageCache setObject:imageObservable forKey:key];
            }
            block(imageObservable);
        }
    });
}
@end
