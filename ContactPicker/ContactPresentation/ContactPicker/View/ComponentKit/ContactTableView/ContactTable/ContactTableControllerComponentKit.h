//
//  ContactTableComponentController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//
#import "ContactDefine.h"
#if BUILD_COMPONENTKIT
#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "ContactTableBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableControllerComponentKit : ContactTableBaseController
- (instancetype)initWithViewModel:(id<ContactViewModelProtocol>) viewModel;
@end

NS_ASSUME_NONNULL_END
#endif
