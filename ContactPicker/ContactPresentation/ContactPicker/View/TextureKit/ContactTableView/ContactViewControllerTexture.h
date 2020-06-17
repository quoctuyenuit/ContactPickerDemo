//
//  ContactViewControllerTexture.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "KeyboardAppearanceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewControllerTexture : ASViewController <UISearchBarDelegate, UITextFieldDelegate, KeyboardAppearanceDelegate>
- (instancetype) initWithViewModel: (id<ContactViewModelProtocol>) viewModel;
@end

NS_ASSUME_NONNULL_END
