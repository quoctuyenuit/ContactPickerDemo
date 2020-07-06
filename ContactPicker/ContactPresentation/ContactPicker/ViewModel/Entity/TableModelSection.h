//
//  TableModelSection.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableModelSection : NSObject
+ (instancetype) section;
@property(nonatomic, copy) NSString         * headerTitle;
@property(nonatomic, copy) NSString         * footerTitle;
@property(nonatomic, strong) NSMutableArray * rows;
@end

NS_ASSUME_NONNULL_END
