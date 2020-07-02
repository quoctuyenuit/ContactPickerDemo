//
//  ContactWithSearchComponent.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/24/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_COMPONENTKIT
#import <Foundation/Foundation.h>
#import "ContactWithSearchBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactWithSearchComponentKit : ContactWithSearchBase
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
#endif
