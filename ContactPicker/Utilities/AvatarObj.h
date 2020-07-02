//
//  AvatarObj.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 7/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataBinding.h"

NS_ASSUME_NONNULL_BEGIN

@interface AvatarObj : NSObject
@property(nonatomic, readwrite) NSString    *identifier;
@property(nonatomic, readwrite) UIImage     *image;
@property(nonatomic, readwrite) NSString    *label;
@property(nonatomic, readwrite) BOOL        isGenerated;

- (instancetype) initWithImage:(UIImage *) image label:(NSString *) label isGenerated:(BOOL) isGenerated identififer:(NSString *) identifier;
@end

NS_ASSUME_NONNULL_END
