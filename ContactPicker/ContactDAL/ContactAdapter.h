//
//  ContactAdapter.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/3/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactAdapterProtocol.h"
#import "APIAdapterProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactAdapter : NSObject<ContactAdapterProtocol>
- (id)initWidthAPI: (id<ImageGeneratorProtocol>) imageAPI;
@end

NS_ASSUME_NONNULL_END
