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
#import "SceneDelegate.h"

@interface ContactTableViewController() {
    __weak IBOutlet UISearchBar *searchBar;
}
@end

@implementation ContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self->searchBar.delegate = self;
    self->searchBar.searchTextField.delegate = self;
    
    self->_viewModel = [[ListContactViewModel alloc] init];
    self.tableView.rowHeight = 60;
    
//    Observe search bar and list of contacts
    [self->_viewModel.numberOfContact bindAndFire:^(NSNumber *numberOfContact) {
        __weak ContactTableViewController *weakSelf = self;
        [weakSelf.tableView reloadData];
    }];
    
    [self->_viewModel.search bindAndFire:^(NSString *text) {
        __weak ContactTableViewController *weakSelf = self;
//        If the listContactOnView changed --> reload tableview, if not do nothing.
        if ([self.viewModel updateListContactWithKey:text]) {
            [weakSelf.tableView reloadData];
        }
    }];
    
    UIWindowScene* windowScene = (UIWindowScene*)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
    SceneDelegate* sceneDelegate = (SceneDelegate*)windowScene.delegate;
    [sceneDelegate.becomeActiveObservable bindAndFire:^(NSNumber * value) {
        [self->_viewModel getAllContact];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return[self->_viewModel getNumberOfContact];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ContactViewCell *cell = (ContactViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ContactViewCell"
                                                                              forIndexPath:indexPath];
    ContactViewModel* model = [_viewModel getContactAt: (int)indexPath.row];
    [cell config:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [searchBar endEditing:YES];
    ContactViewCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    [selectedCell select];
}

#pragma mark - Searchbar view delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.viewModel.search.value = searchText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [searchBar endEditing:YES];
    return YES;
}
@end
