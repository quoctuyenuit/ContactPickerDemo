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
#import "Utilities.h"
#import "ContactViewEntity.h"
#import "Logging.h"

#define CELL_REUSE_IDENTIFIER       @"ContactViewCell"

@interface ContactTableViewController() <UITableViewDelegate, UITableViewDataSource>
@end

@implementation ContactTableViewController {
    UITableView                     * _tableView;
    id<ContactViewModelProtocol>      _viewModel;
}

@synthesize keyboardAppearanceDelegate;

- (id)initWithViewModel:(id<ContactViewModelProtocol>)viewModel {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel              = viewModel;
        _tableView              = [[UITableView alloc] init];
        _tableView.delegate     = self;
        _tableView.dataSource   = self;
    }
    return self;
}

#pragma mark - Life circle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:_tableView];
    UINib *nib = [UINib nibWithNibName:@"ContactTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
}
- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  _tableView.frame = self.view.bounds;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self->_viewModel numberOfSection];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate * time = [[NSDate alloc] init];
    NSLog(@"[ContactTableViewController] numberOfRowsInSection, time = %f", [time timeIntervalSince1970]);
    return [self->_viewModel numberOfContactInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ContactTableViewCell *cell = (ContactTableViewCell*)[tableView dequeueReusableCellWithIdentifier: CELL_REUSE_IDENTIFIER
                                                                              forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithFrame:CGRectZero];
    }
    
    ContactViewEntity *entity = [self->_viewModel contactAtIndex: indexPath];
    [cell configForModel:entity];
    
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self->_viewModel getAllSectionNames];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self->_viewModel numberOfContactInSection:section] > 0 ? [self->_viewModel titleForHeaderInSection:section] : nil;
}

#pragma mark - UITableDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ContactTableViewCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    
    [self->_viewModel selectectContactAtIndex:indexPath];
    
    [selectedCell setSelect];
    
    [self.keyboardAppearanceDelegate hideKeyboard];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"[ContactTableViewController] scrollViewDidScroll");
    CGFloat currentOffSetY = scrollView.contentOffset.y;
    CGFloat contentHeight  = scrollView.contentSize.height;
    CGFloat screenHeight   = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat screenfullsBeforeBottom = (contentHeight - currentOffSetY) / screenHeight;
    if (screenfullsBeforeBottom < AUTO_TAIL_LOADING_NUM_SCREENFULS) {
        [self loadMoreContacts];
    }
}

#pragma mark - Subclass methods
- (UITableView *)tableView {
    return _tableView;
}

- (id<ContactViewModelProtocol>)viewModel {
    return _viewModel;
}

- (void)loadMoreContacts {
    NSLog(@"[ContactTableViewController] load batch");
    __weak typeof(self) weakSelf = self;
    [_viewModel loadBatchOfContacts:^(NSError *error, NSArray<NSIndexPath *> *updatedIndexPaths) {
        NSLog(@"[ContactTableViewController] load batch respose");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error) {
                [Logging error:error.localizedDescription];
            } else {
                [strongSelf insertCells:updatedIndexPaths];
            }
        }
    }];
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    ContactTableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
    [cell setSelect];
}

- (void)reloadContacts {
    NSLog(@"[ContactTableViewController] reload");
    [_tableView reloadData];
    NSIndexPath * firstIndex = [_viewModel firstContactOnView];
    if (firstIndex) {
        [_tableView scrollToRowAtIndexPath:firstIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}
@end
