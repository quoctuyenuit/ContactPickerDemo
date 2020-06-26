//
//  ContactTableViewController.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableControllerUIKit.h"
#import "ContactViewModelProtocol.h"
#import "ContactTableViewCell.h"
#import "Utilities.h"
#import "ContactViewEntity.h"
#import "Logging.h"

#define CELL_REUSE_IDENTIFIER       @"ContactViewCell"
#define LOG_MSG_HEADER              @"ContactTableUIKit"

@interface ContactTableControllerUIKit() <UITableViewDelegate, UITableViewDataSource>
@end

@implementation ContactTableControllerUIKit {
    UITableView                     * _tableView;
    id<ContactViewModelProtocol>      _viewModel;
}

@synthesize keyboardAppearanceDelegate;

- (id)initWithViewModel:(id<ContactViewModelProtocol>)viewModel {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel              = viewModel;
        _tableView              = [[UITableView alloc] init];
    }
    return self;
}

#pragma mark - Life circle methods
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
    if (!self.contactHadLoad)
        return 0;
//    NSInteger rows = [self->_viewModel numberOfContactInSection:section];
//    if (rows > 0)
//        NSLog(@"[%@] numberOfRows is called", LOG_MSG_HEADER);
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
    if (!self.contactHadLoad)
        return;
    
    CGFloat currentOffSetY = scrollView.contentOffset.y;
    CGFloat contentHeight  = scrollView.contentSize.height;
    CGFloat screenHeight   = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat screenfullsBeforeBottom = (contentHeight - currentOffSetY) / screenHeight;
    if (screenfullsBeforeBottom < AUTO_TAIL_LOADING_NUM_SCREENFULS) {
        NSLog(@"[%@] begin fetching from scroll", LOG_MSG_HEADER);
        [self fetchBatchContactWithBlock:nil];
    }
}

#pragma mark - Subclass methods
- (id<ContactViewModelProtocol>)viewModel {
    return _viewModel;
}

- (void)setupBaseViews {
    [self.view addSubview:_tableView];
    UINib *nib = [UINib nibWithNibName:@"ContactTableViewCell" bundle:nil];
    [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
    
    _tableView.showsHorizontalScrollIndicator          = NO;
    _tableView.showsVerticalScrollIndicator            = NO;
    _tableView.separatorStyle                          = UITableViewScrollPositionNone;
    _tableView.backgroundColor                         = UIColor.whiteColor;
    _tableView.rowHeight                               = 66;
    _tableView.delegate                                = self;
    _tableView.dataSource                              = self;
}

- (void)setupDatasets {
    
}

- (void)reloadTable {
    [_tableView reloadData];
    NSIndexPath * firstIndex = [_viewModel firstContactOnView];
    if (firstIndex) {
        NSLog(@"[%@] reload table - scroll top at: [%ld, %ld], current cell in this section is: %ld", LOG_MSG_HEADER, firstIndex.row, firstIndex.section, [_tableView numberOfRowsInSection:firstIndex.section]);
        [_tableView scrollToRowAtIndexPath:firstIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)insertCells:(NSArray<NSIndexPath *> *)indexPaths forEntities:(NSArray<ContactViewEntity *> *)entities {
    NSLog(@"[%@] begin insert cell from %ld indexs", LOG_MSG_HEADER, indexPaths.count);
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)removeCells:(NSArray<NSIndexPath *> *)indexPaths {
    NSLog(@"[%@] begin remove cell from %ld indexs", LOG_MSG_HEADER, indexPaths.count);
    [_tableView reloadData];
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    ContactTableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
    [cell setSelect];
}
@end
