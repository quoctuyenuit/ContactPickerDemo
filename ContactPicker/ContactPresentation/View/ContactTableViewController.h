//
//  ContactTableViewController.h
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListContactViewModel.h"
#import "ContactViewEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate>
@property (nonatomic, readwrite)  IBOutlet UITableView *tableView;
@property (nonatomic, readwrite)  IBOutlet UISearchBar *searchBar;

@property (nonatomic, readwrite) NSMutableArray<ContactViewEntity *> * listEntities;

@end

NS_ASSUME_NONNULL_END
