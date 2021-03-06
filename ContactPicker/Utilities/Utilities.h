//
//  Utilities.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - UIImage Exrtension
@interface UIImage(Addition)
- (UIImage *)makeCircularImageWithSize:(CGSize)size backgroundColor:(UIColor * _Nullable)backgroundColor;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
@end

#pragma mark - UIColor Exrtension
@interface UIColor(extension)
+ (UIColor *) colorFromHex: (NSString *) hex;
+ (UIColor *) contactNameColor;
+ (UIColor *) contactDescriptionColor;
+ (UIColor *) appColor;
@end

#pragma mark - GradientColors
@interface GradientColors : NSObject {
    NSMutableArray * _colorsTable;
}

+ (id) instantiate;
- (NSArray *) colorForKey:(NSString *) key;
- (NSArray *) randomColor;
@end

#pragma mark - NSArray Exrtension
@interface NSArray(Addition)
- (NSArray*) map: (id (^)(id obj)) block;
- (NSArray *)filter:(BOOL (^)(id obj))block;
- (id)reduce:(id)initial
       block:(id (^)(id obj1, id obj2))block;
- (NSArray *)flatMap:(id (^)(id obj))block;

- (id _Nullable) firstObjectWith: (BOOL (^)(id obj)) block;

- (BOOL) containsObjectWith: (BOOL (^)(id obj)) block;
@end


#pragma mark - NSAttributedString Extension
@interface NSAttributedString (Additions)

+ (NSAttributedString *)attributedStringWithString:(NSString *)string
                                          fontSize:(CGFloat)size
                                             color:(nullable UIColor *)color
                                    firstWordColor:(nullable UIColor *)firstWordColor;

+ (NSAttributedString *)attributedStringWithString:(NSString *)string
                                              font:(UIFont *)font
                                             color:(nullable UIColor *)color
                                    firstWordColor:(nullable UIColor *)firstWordColor;

@end

#pragma mark - ASDisplayNode Extension
typedef enum : NSUInteger {
    ASDisplayGradientDirectionVertical,
    ASDisplayGradientDirectionHorizontal,
} ASDisplayGradientDirection;

struct ASDisplayGradientPoints {
    CGPoint start;
    CGPoint end;
};

@interface ASDisplayNode(Addition)
- (void) gradientBackgroundColor: (NSArray<UIColor *> *) colors direction: (ASDisplayGradientDirection) direction;
@end

@interface NSString(Addition)
- (BOOL) hasPrefixLower: (NSString *) key;
@end

//@interface GrandCentralDispatch: NSObject
//+ (GrandCentralDispatch *) main;
//+ (GrandCentralDispatch *) background;
//+ (GrandCentralDispatch *) concurrent:(dispatch_queue_priority_t) priority;
//+ (GrandCentralDispatch *) serial:(dispatch_queue_priority_t) priority;
//@end

@interface UIView(Addition)
- (void)dropShadow: (BOOL) scale;

- (void)dropShadow;
@end

#pragma mark - CAGradient Extension
@interface CAGradientLayer(Addition)
+ gradientWithSize:(CGRect) frame colors:(NSArray * _Nullable) colors;
@end

NS_ASSUME_NONNULL_END
