//
//  ContactTableViewController.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableViewController.h"
#import "ContactViewModelProtocol.h"
#import "ContactTableViewCell.h"
#import "NSArrayExtension.h"
#import "ContactViewEntity.h"

@interface ContactTableViewController() {
    id<ContactViewModelProtocol> viewModel;
    NSString * cellReuseIdentifier;
}
- (void) setupView;
- (void) insertCells: (int) index withSize: (int) size;
- (BOOL) checkNeedLoadBatch: (BOOL) hasIndexPath index: (int) index;
@end

@implementation ContactTableViewController

@synthesize keyboardAppearanceDelegate;

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
//    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//    for (int i = [self->viewModel getNumberOfContacts] - size; i < index + size; i++) {
//        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//    }
//
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationNone)];
//    [self.tableView endUpdates];
    
}

- (BOOL)checkNeedLoadBatch: (BOOL) hasIndexPath index:(int)index {
    int offset = 10;
    if (hasIndexPath) {
        return index > [self->viewModel getNumberOfContacts] - offset;
    } else {
        NSArray<NSIndexPath *> * visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
        if (visibleIndexPaths.count > 0) {
            int lastIndex = (int)visibleIndexPaths.lastObject.row;
            return lastIndex > [self->viewModel getNumberOfContacts] - offset;
        }
        return NO;
    }
}

#pragma mark - Override function

- (id)initWithViewModel:(id<ContactViewModelProtocol>)viewModel {
    self = [super initWithNibName:nil bundle:nil];
    self->viewModel = viewModel;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self->viewModel.contactBookObservable binding:^(NSNumber * number) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [self->viewModel.searchObservable binding:^(NSString * searchText) {
        [self->viewModel searchContactWithKeyName:searchText completion:^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        
    }];
    
    [self->viewModel.indexCellNeedUpdateObservable binding:^(NSNumber * indexChangedCell) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[indexChangedCell intValue] inSection:0];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation: (UITableViewRowAnimationNone)];
        [self.tableView endUpdates];
    }];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
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
    
    if (!cell.delegate) {
        cell.delegate = self;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    ContactTableViewCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    ContactViewEntity * entity = [self->viewModel getContactAt:(int)indexPath.row];
    
    [self->viewModel selectectContactAtIndex:(int)indexPath.row];
    [selectedCell setSelect];
    
    [self.keyboardAppearanceDelegate hideKeyboard];
    [self.contactDelegate didSelectContact:entity];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self checkNeedLoadBatch:YES index:(int)indexPath.row]) {
        [self->viewModel loadBatchOfDetailedContacts: ^(BOOL isSuccess, NSError * error, int batchLength) {
            if (isSuccess) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self.tableView reloadData];
                });
            }
        }];
    }
}

- (void)didSelectContact:(ContactViewEntity *)contact {
    [self->viewModel selectectContactIdentifier:contact.identifier];
    [self.contactDelegate didSelectContact:contact];
}

@end
