//
//  ContactViewController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewController : UIViewController <UISearchBarDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

NS_ASSUME_NONNULL_END
