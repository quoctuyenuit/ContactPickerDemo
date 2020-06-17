//
//  ContactTableNodeController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModel.h"
#import "KeyboardAppearanceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableNodeController : ASViewController<KeyboardAppearanceProtocol>
- (instancetype) initWithModel: (ContactViewModel *) viewModel;
@end

NS_ASSUME_NONNULL_END
