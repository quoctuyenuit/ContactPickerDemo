//
//  ContactViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactTableViewController.h"
#import "ContactViewModel.h"

#import "ContactBus.h"
#import "ContactAdapter.h"
#import "ImageGeneratorAPIAdapter.h"

@interface ContactViewController () {
    ContactTableViewController * contactTableController;
    ContactViewModel * viewModel;
}
- (UITableViewController *) loadContactTableView;
- (void) setupViews;
- (void) setupEvents;
@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self->viewModel = [[ContactViewModel alloc] initWithBus: [[ContactBus alloc] initWithAdapter:[[ContactAdapter alloc] initWidthAPI:[[ImageGeneratorAPIAdapter alloc] init]]]];
    self->contactTableController = [[ContactTableViewController alloc] initWithViewModel:viewModel];

    [self setupViews];
    [self setupEvents];
    
}

- (void)setupViews {
    [self addChildViewController:self->contactTableController];
    [self.view addSubview:self->contactTableController.view];
    
    self->contactTableController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self->contactTableController.view.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor].active = YES;
    [self->contactTableController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self->contactTableController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self->contactTableController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

- (UITableViewController *)loadContactTableView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ContactTableViewStoryboard" bundle:nil];
    UITableViewController *contactTableViewController = (UITableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ContactTableViewController"];
    return contactTableViewController;
}

- (void)setupEvents {
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.delegate = self;
    
    [self->viewModel.search bindAndFire:^(NSString * searchText) {
        [self->viewModel searchContactWithKeyName:searchText completion:^(BOOL isNeedReload) {
            if (isNeedReload) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->contactTableController.tableView reloadData];
                });
            }
        }];
    }];
}

#pragma mark - Searchbar view delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self->viewModel.search.value = searchText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchBar endEditing:YES];
    return YES;
}

@end
