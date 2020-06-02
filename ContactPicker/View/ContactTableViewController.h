//
//  ContactTableViewController.h
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
@property ListContactViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
