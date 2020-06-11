//
//  GradientColors.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/11/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "GradientColors.h"
#import "UIColorExtension.h"

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
