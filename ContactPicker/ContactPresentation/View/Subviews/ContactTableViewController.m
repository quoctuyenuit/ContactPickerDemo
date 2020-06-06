//
//  ContactTableViewController.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableViewController.h"
#import "ContactViewModel.h"
#import "ContactTableViewCell.h"
#import "NSArrayExtension.h"
#import "ContactViewEntity.h"

@interface ContactTableViewController() {
    ContactViewModel* viewModel;
    NSString * cellReuseIdentifier;
}
- (void) setupView;
- (void) insertCells: (int) index withSize: (int) size;
- (void) loadContacts;
@end

@implementation ContactTableViewController

#pragma mark - Custom function

- (void)setupView {
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = UIColor.whiteColor;
    UINib *nib = [UINib nibWithNibName:@"ContactTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ContactViewCell"];
    self.tableView.rowHeight = 60;
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

#pragma mark - Override function

- (id)initWithViewModel:(ContactViewModel *)viewModel {
    self = [super initWithNibName:nil bundle:nil];
    self->viewModel = viewModel;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self loadContacts];
    
    [self->viewModel.updateContacts binding:^(NSArray * listIndexNeedUpdate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i = 0; i < listIndexNeedUpdate.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
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
    [self setupView];
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
    
    ContactViewEntity *entity = [self->viewModel getContactAt: (int)indexPath.row];
    [cell configForModel:entity];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    ContactTableViewCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    ContactViewEntity * entity = [self->viewModel getContactAt:(int)indexPath.row];
    entity.isChecked = !entity.isChecked;
    
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

@end
