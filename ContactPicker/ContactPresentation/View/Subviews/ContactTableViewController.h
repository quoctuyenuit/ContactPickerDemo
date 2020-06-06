//
//  ContactTableViewController.h
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewController : UITableViewController
- (id) initWithViewModel: (ContactViewModel *) viewModel;
@end

NS_ASSUME_NONNULL_END
