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

#define CACHE_SIZE              5

@interface ImageManager ()
- (UIImage *) _createGradientImageWithSize:(CGSize) size colors:(NSArray *) colors;
- (instancetype) _initWithSize:(NSInteger) size;
- (UIImage *) _randomImage;
- (void) _createColorsTable;
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

- (instancetype)_initWithSize:(NSInteger) size {
    _imageCache                 = [[NSCache alloc] init];
    _imageCache.totalCostLimit  = size;
    _contactAdapter             = [[ContactAdapter alloc] init];
    _colorsTable                = [[NSMutableArray alloc] init];
    _generatedImages            = [[NSMutableArray alloc] init];
    
    _backgroundQueue            = dispatch_queue_create("ContactBus search queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    [self _createColorsTable];
    return self;
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

- (void)_createColorsTable {
    [_colorsTable addObject:@[(id)[UIColor colorFromHex:@"#7bd5f5"].CGColor, (id)[UIColor colorFromHex:@"#787ff6"].CGColor]];
    [_colorsTable addObject:@[(id)[UIColor colorFromHex:@"#787ff6"].CGColor, (id)[UIColor colorFromHex:@"#4adede"].CGColor]];
    [_colorsTable addObject:@[(id)[UIColor colorFromHex:@"#4adede"].CGColor, (id)[UIColor colorFromHex:@"#1ca7ec"].CGColor]];
    [_colorsTable addObject:@[(id)[UIColor colorFromHex:@"#667db6"].CGColor, (id)[UIColor colorFromHex:@"#0082c8"].CGColor, (id)[UIColor colorFromHex:@"#0082c8"].CGColor, (id)[UIColor colorFromHex:@"#667db6"].CGColor]];
    [_colorsTable addObject:@[(id)[UIColor colorFromHex:@"#ff9190"].CGColor, (id)[UIColor colorFromHex:@"#fdc094"].CGColor]];
    [_colorsTable addObject:@[(id)[UIColor colorFromHex:@"#659999"].CGColor, (id)[UIColor colorFromHex:@"#f4791f"].CGColor]];
    [_colorsTable addObject:@[(id)[UIColor colorFromHex:@"#ff9a9e"].CGColor, (id)[UIColor colorFromHex:@"#fecfef"].CGColor]];
    [_colorsTable addObject:@[(id)[UIColor colorFromHex:@"#c79081"].CGColor, (id)[UIColor colorFromHex:@"#dfa579"].CGColor]];
    
    for (NSArray * colors in _colorsTable) {
        [_generatedImages addObject: [self _createGradientImageWithSize:CGSizeMake(AVATAR_IMAGE_HEIGHT, AVATAR_IMAGE_HEIGHT)
                                                                  colors:colors]];
    }
}

#pragma mark - Public methods
- (void)imageForKey:(NSString *)key
              label:(NSString *) label
              block:(void (^)(AvatarObj * _Nonnull imgObj, NSString * key))block {
    if (!block) {
        return;
    }
    if (key == nil) {
        return;
    }
    
    weak_self
    __weak typeof(key) weakKey = key;
    __weak typeof(label) weakLabel = label;
    dispatch_async(_backgroundQueue, ^{
        strong_self
        if (strongSelf) {
            AvatarObj * imgObj = [strongSelf.imageCache objectForKey:weakKey];
            if (imgObj) {
                block(imgObj, weakKey);
                return;
            }
            UIImage * image = [strongSelf _randomImage];
            imgObj = [[AvatarObj alloc] initWithImage:image label:weakLabel isGenerated:YES];
            [strongSelf.imageCache setObject:imgObj forKey:weakKey];
            block(imgObj, weakKey);
            
            [strongSelf.contactAdapter getImageById:weakKey block:^(UIImage *image, NSError *error) {
                strong_self
                if (strongSelf) {
                    if (image) {
                        AvatarObj * imgObj = [[AvatarObj alloc] initWithImage:image label:@"" isGenerated:NO];
                        [strongSelf.imageCache setObject:imgObj forKey:weakKey];
                        block(imgObj, weakKey);
                    }
                }
            }];
        }
    });
}
@end
