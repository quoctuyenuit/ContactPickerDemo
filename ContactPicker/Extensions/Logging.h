//
//  Logging.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/8/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Logging : NSObject
+ (void) info: (NSString *) msg;
+ (void) exeption: (NSString *) msg;
+ (void) error: (NSString *) msg;
@end

NS_ASSUME_NONNULL_END
