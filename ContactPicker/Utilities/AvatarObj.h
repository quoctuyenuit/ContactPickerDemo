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
@property(nonatomic, readwrite) BOOL        isLoaded;
@property(nonatomic, readonly) UIImage     *image;
@property(nonatomic, assign) BOOL           isGenerated;

- (instancetype) initWithImage:(UIImage *) image isGenerated:(BOOL) isGenerated;
@end

NS_ASSUME_NONNULL_END
