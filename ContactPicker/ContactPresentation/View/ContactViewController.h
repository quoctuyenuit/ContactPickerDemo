//
//  ContactViewController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewModelProtocol.h"
#import "KeyboardAppearanceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewController : UIViewController <UISearchBarDelegate, UITextFieldDelegate, KeyboardAppearanceDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
+ (ContactViewController *) instantiateWith: (id<ContactViewModelProtocol>) viewModel;
@end

NS_ASSUME_NONNULL_END
