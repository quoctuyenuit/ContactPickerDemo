//
//  ContactTableViewController.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableViewController.h"
#import "ContactViewCell.h"
#import "ListContactViewModel.h"
#import "DataBinding.h"

@interface ContactTableViewController () {
    __weak IBOutlet UISearchBar *searchBar;
}
@end

@implementation ContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewModel = [[ListContactViewModel alloc] init];
    self.tableView.rowHeight = 60;
    
    searchBar.delegate = self;
    
    [_viewModel.search bindAndFire:^(NSString *text) {
        __weak ContactTableViewController *weakSelf = self;
//        If the listContactOnView changed --> reload tableview, if not do nothing.
        if ([self.viewModel updateListContactWithKey:text]) {
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return[_viewModel getNumberOfContact];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactViewCell *cell = (ContactViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactViewCell" forIndexPath:indexPath];
    
    ContactViewModel* model = [_viewModel getContactAt: (int)indexPath.row];
    
    [cell config:model];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - Searchbar view delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.viewModel.search.value = searchText;
}

@end
