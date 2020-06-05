//
//  ContactTableViewController.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableViewController.h"
#import "ListContactViewModel.h"
#import "ContactTableViewCell.h"
#import "NSArrayExtension.h"
#import "ContactViewModel.h"

#import "ContactBus.h"
#import "ContactAdapter.h"
#import "ImageGeneratorAPIAdapter.h"

@interface ContactTableViewController() {
    ListContactViewModel* viewModel;
    NSString * cellReuseIdentifier;
}
- (void) customInit;
- (void) setupView;
- (void) insertCells: (int) index withSize: (int) size;
- (void) loadContacts;
@end

@implementation ContactTableViewController

#pragma mark - Override function
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self loadContacts];
    
    [self->viewModel.search bindAndFire:^(NSString * searchText) {
        [self->viewModel searchContactWithKeyName:searchText completion:^(BOOL isNeedReload) {
            if (isNeedReload) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
    }];
    
    [self->viewModel.updateContacts binding:^(NSArray * listIndexNeedUpdate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i = 0; i < listIndexNeedUpdate.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
//            [self.tableView reloadData];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation: (UITableViewRowAnimationNone)];
            [self.tableView endUpdates];
        });
    }];
    
}

- (void)loadContacts {
    [self->viewModel loadContacts: ^(BOOL isSuccess, int length) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = UIColor.whiteColor;
    [self setupView];
}

#pragma mark - Custom function

- (void)customInit {
    self->viewModel = [[ListContactViewModel alloc] initWithBus: [[ContactBus alloc] initWithAdapter:[[ContactAdapter alloc] initWidthAPI:[[ImageGeneratorAPIAdapter alloc] init]]]];
    
}

- (void) insertCells: (int) index withSize: (int) size {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = index; i < index + size; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationNone)];
    [self.tableView endUpdates];
}

- (void)setupView {
    UINib *nib = [UINib nibWithNibName:@"ContactTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ContactViewCell"];
    self.tableView.rowHeight = 60;
    
    self.searchBar.delegate = self;
    self.searchBar.searchTextField.delegate = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self->viewModel getNumberOfContacts];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ContactTableViewCell *cell = (ContactTableViewCell*)[tableView dequeueReusableCellWithIdentifier: @"ContactViewCell"
                                                                              forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithFrame:CGRectZero];
    }
    
    ContactViewModel *entity = [self->viewModel getContactAt: (int)indexPath.row];
    [cell configForModel:entity];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    ContactTableViewCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    ContactViewModel * model = [self->viewModel getContactAt:(int)indexPath.row];
    model.isChecked = !model.isChecked;
    
    [selectedCell setSelect];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self->viewModel getNumberOfContacts] - 5) {
        int itemsOnViewCount = [self->viewModel getNumberOfContacts];
        [self->viewModel loadBatch: ^(BOOL loadDone, int batchLength) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self->viewModel getNumberOfContacts] > itemsOnViewCount) // If actually append item on view
                    [self insertCells: [self->viewModel getNumberOfContacts] - batchLength withSize: batchLength];
            });
        }];
    }
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
