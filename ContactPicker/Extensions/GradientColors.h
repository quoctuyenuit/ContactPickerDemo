//
//  GradientColors.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/11/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GradientColors : NSObject {
    NSMutableArray * colorsTable;
}

+ (id) instantiate;
- (NSArray *) randomColor;
@end

NS_ASSUME_NONNULL_END
