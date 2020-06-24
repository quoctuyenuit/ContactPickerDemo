//
//  ContactTableComponentController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableComponentController : UICollectionViewController
- (instancetype)initWithViewModel: (id<ContactViewModelProtocol>) viewModel;
@end

NS_ASSUME_NONNULL_END
