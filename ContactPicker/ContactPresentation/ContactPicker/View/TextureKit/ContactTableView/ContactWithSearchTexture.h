//
//  ContactViewControllerTexture.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_TEXTURE
#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "KeyboardAppearanceDelegate.h"
#import "ContactCollectionCellProtocol.h"
#import "ContactWithSearchBase.h"


NS_ASSUME_NONNULL_BEGIN

@interface ContactWithSearchTexture : ContactWithSearchBase
- (instancetype) init;
@end

NS_ASSUME_NONNULL_END
#endif
