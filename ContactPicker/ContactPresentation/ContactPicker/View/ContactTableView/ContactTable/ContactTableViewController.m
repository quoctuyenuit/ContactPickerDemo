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
    id<ContactViewModelProtocol> _viewModel;
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
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f / %f", scrollView.contentOffset.y, scrollView.contentSize.height);
    
}

#pragma mark - Override function

- (id)initWithViewModel:(id<ContactViewModelProtocol>)viewModel {
    self = [super initWithNibName:nil bundle:nil];
    self->_viewModel = viewModel;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    __weak ContactTableViewController * weakSelf = self;
    
    [self->_viewModel.contactBookObservable binding:^(NSNumber * number) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
    
    [self->_viewModel.searchObservable binding:^(NSString * searchText) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf->_viewModel searchContactWithKeyName:searchText];
    }];
    
    [self->_viewModel.contactAddedObservable bindAndFire:^(NSArray<NSIndexPath *> * indexPaths) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
//            [self.tableView beginUpdates];
//            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView endUpdates];
//
        });
    }];
    
    
    [self->_viewModel.indexCellNeedUpdateObservable binding:^(NSIndexPath * indexPath) {
        //[weakSelf.tableView performBatchUpdates:^{
//        [weakSelf tableView:weakSelf.tableView didSelectRowAtIndexPath:indexPath];
//        [weakSelf.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationFade];
        //} completion:nil];
    }];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (void)loadView {
    [super loadView];
    [self setupView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self->_viewModel numberOfSection];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self->_viewModel numberOfContactInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ContactTableViewCell *cell = (ContactTableViewCell*)[tableView dequeueReusableCellWithIdentifier: @"ContactViewCell"
                                                                              forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithFrame:CGRectZero];
    }
    
    ContactViewEntity *entity = [self->_viewModel contactAtIndex: indexPath];
    [cell configForModel:entity];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    ContactTableViewCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    
    ContactViewEntity * entity = [self->_viewModel contactAtIndex:indexPath];
    
    [self->_viewModel selectectContactAtIndex:indexPath];
    
    [selectedCell setSelect];
    
    [self.keyboardAppearanceDelegate hideKeyboard];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self->_viewModel getAllSectionNames];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self->_viewModel numberOfContactInSection:section] > 0 ? [self->_viewModel titleForHeaderInSection:section] : nil;
}


@end
