//
//  ContactTableComponentController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactTableBaseController.h"
#import "ContactViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableComponentController : ContactTableBaseController
- (instancetype)initWithViewModel: (id<ContactViewModelProtocol>) viewModel;
@end

NS_ASSUME_NONNULL_END
