//
//  ContactTableNodeController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "ContactTableBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableControllerTexture : ContactTableBaseController
- (instancetype)initWithViewModel: (id<ContactViewModelProtocol>) viewModel;
@end

NS_ASSUME_NONNULL_END
