//
//  Utilities.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "Utilities.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

#define StrokeRoundedImages 0




#pragma mark - UIImage Extension
@implementation UIImage(Addition)
- (UIImage *)makeCircularImageWithSize:(CGSize)size backgroundColor:(UIColor * _Nullable)backgroundColor
{
    // make a CGRect with the image's size
    CGRect circleRect = (CGRect) {CGPointZero, size};
    
    // begin the image context since we're not in a drawRect:
    UIGraphicsBeginImageContextWithOptions(circleRect.size, backgroundColor != nil, 0);
    
    // Draw background color for opaqueness
    if (backgroundColor) {
        [backgroundColor set];
        UIRectFill(circleRect);
    }
    
    // create a UIBezierPath circle
    UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRect.size.width/2];
    
    // clip to the circle
    [circle addClip];
    
    // draw the image in the circleRect *AFTER* the context is clipped
    [self drawInRect:circleRect];
    
    // create a border (for white background pictures)
#if StrokeRoundedImages
    circle.lineWidth = 1;
    [[UIColor darkGrayColor] set];
    [circle stroke];
#endif
    
    // get an image from the image context
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the image context since we're not in a drawRect:
    UIGraphicsEndImageContext();
    
    return roundedImage;
}
@end

#pragma mark - UIColor Extension
@implementation UIColor(extension)
+ (UIColor *)colorFromHex:(NSString *)hex {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)contactNameColor {
    return UIColor.blackColor;
}

+ (UIColor *)contactDescriptionColor {
    return UIColor.grayColor;
}
@end


#pragma mark - GradientColors

@implementation GradientColors
+ (id)instantiate {
    GradientColors * gc = [[GradientColors alloc] init];
    gc->colorsTable = [[NSMutableArray alloc] init];
    [gc->colorsTable addObject:@[(id)[UIColor colorFromHex:@"#7bd5f5"].CGColor, (id)[UIColor colorFromHex:@"#787ff6"].CGColor]];
    [gc->colorsTable addObject:@[(id)[UIColor colorFromHex:@"#787ff6"].CGColor, (id)[UIColor colorFromHex:@"#4adede"].CGColor]];
    [gc->colorsTable addObject:@[(id)[UIColor colorFromHex:@"#4adede"].CGColor, (id)[UIColor colorFromHex:@"#1ca7ec"].CGColor]];
    [gc->colorsTable addObject:@[(id)[UIColor colorFromHex:@"#667db6"].CGColor, (id)[UIColor colorFromHex:@"#0082c8"].CGColor, (id)[UIColor colorFromHex:@"#0082c8"].CGColor, (id)[UIColor colorFromHex:@"#667db6"].CGColor]];
    [gc->colorsTable addObject:@[(id)[UIColor colorFromHex:@"#ff9190"].CGColor, (id)[UIColor colorFromHex:@"#fdc094"].CGColor]];
    [gc->colorsTable addObject:@[(id)[UIColor colorFromHex:@"#659999"].CGColor, (id)[UIColor colorFromHex:@"#f4791f"].CGColor]];
    [gc->colorsTable addObject:@[(id)[UIColor colorFromHex:@"#ff9a9e"].CGColor, (id)[UIColor colorFromHex:@"#fecfef"].CGColor]];
    [gc->colorsTable addObject:@[(id)[UIColor colorFromHex:@"#c79081"].CGColor, (id)[UIColor colorFromHex:@"#dfa579"].CGColor]];
    return gc;
}

- (NSArray *)randomColor {
    NSUInteger index = arc4random_uniform((uint32_t)self->colorsTable.count);
    return self->colorsTable[index];
}
@end

#pragma mark - NSArray Extension
@implementation NSArray(Addition)
- (NSArray *)map:(id  _Nonnull (^)(id _Nonnull))block {
    NSMutableArray* results = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [results addObject:block(obj)];
    }];
    return [results copy];
}

- (NSArray *)filter:(BOOL (^)(id obj))block {
    NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj) == YES) {
            [mutableArray addObject:obj];
        }
    }];
    return [mutableArray copy];
}

- (id)reduce:(id)initial
       block:(id (^)(id obj1, id obj2))block {
    __block id obj = initial;
    [self enumerateObjectsUsingBlock:^(id _obj, NSUInteger idx, BOOL *stop) {
        obj = block(obj, _obj);
    }];
    return obj;
}

- (NSArray *)flatMap:(id (^)(id obj))block {
    NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id _obj = block(obj);
        if ([_obj isKindOfClass:[NSArray class]]) {
            NSArray *_array = [_obj flatMap:block];
            [mutableArray addObjectsFromArray:_array];
            return;
        }
        [mutableArray addObject:_obj];
    }];
    return [mutableArray copy];
}

- (id _Nullable)firstObjectWith:(BOOL (^)(id _Nonnull))block {
    for (id obj in self) {
        if (block(obj))
            return obj;
    }
    
    return nil;
}

- (BOOL)containsObjectWith:(BOOL (^)(id _Nonnull))block {
    for (id obj in self) {
        if (block(obj))
            return YES;
    }
    return NO;
}
@end

#pragma mark - NSAttributedString Extension

@implementation NSAttributedString (Additions)

+ (NSAttributedString *)attributedStringWithString:(NSString *)string fontSize:(CGFloat)size
                                             color:(nullable UIColor *)color firstWordColor:(nullable UIColor *)firstWordColor
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    if (string) {
        NSDictionary *attributes = @{NSForegroundColorAttributeName: color ? : [UIColor blackColor],
                                     NSFontAttributeName: [UIFont systemFontOfSize:size]};
        attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        [attributedString addAttributes:attributes range:NSMakeRange(0, string.length)];
        
        if (firstWordColor) {
            NSRange firstSpaceRange = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
            NSRange firstWordRange  = NSMakeRange(0, firstSpaceRange.location);
            [attributedString addAttribute:NSForegroundColorAttributeName value:firstWordColor range:firstWordRange];
        }
    }
    
    return attributedString;
}

@end

#pragma mark - ASDisplayNode Extension

@implementation ASDisplayNode(Addition)

- (struct ASDisplayGradientPoints) parseGradientDirection: (ASDisplayGradientDirection) direction {
    struct ASDisplayGradientPoints point;
    switch (direction) {
        case ASDisplayGradientDirectionVertical:
            point.start.x   = 0.5;
            point.start.y   = 0;
            point.end.x     = 0.5;
            point.end.y     = 1;
            return point;
        case ASDisplayGradientDirectionHorizontal:
            point.start.x   = 0;
            point.start.y   = 0.5;
            point.end.x     = 1;
            point.end.y     = 0.5;
            return point;
        default:
            NSAssert(NO, @"Not implemented");
            break;
    }
}

- (CAGradientLayer *)gradientLayer {
    if (self.layer.sublayers) {
        return [self.layer.sublayers filter:^BOOL(id  _Nonnull obj) {
            return [obj isKindOfClass:[CAGradientLayer class]];
        }].firstObject;
    }
    return nil;
}

- (void)gradientBackgroundColor:(NSArray<UIColor *> *)colors direction:(ASDisplayGradientDirection)direction {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundColor            = UIColor.clearColor;
        self.clipsToBounds              = true;
        CAGradientLayer * gradient      = [self gradientLayer];
        if (!gradient) {
            gradient = [[CAGradientLayer alloc] init];
            gradient.frame                  = CGRectMake(0, 0, self.calculatedSize.width, self.calculatedSize.height);
            [self.layer insertSublayer:gradient atIndex:0];
        }
        
        gradient.colors                 = colors;
        struct ASDisplayGradientPoints gradientPoints = [self parseGradientDirection:direction];
        gradient.startPoint             = gradientPoints.start;
        gradient.endPoint               = gradientPoints.end;
        
    });
}
@end
