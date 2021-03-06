//
//  ContactTableViewController.m
//  ContactPicker
//
//  Created by LAP13528 on 6/2/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactDefine.h"

#if BUILD_UIKIT
#import "ContactTableControllerUIKit.h"
#import "ContactViewModelProtocol.h"
#import "ContactTableViewCell.h"
#import "Utilities.h"
#import "ContactViewEntity.h"
#import "ContactGlobalConfigure.h"


#define CELL_REUSE_IDENTIFIER       @"ContactViewCell"

@interface ContactTableControllerUIKit() <UITableViewDelegate, UITableViewDataSource, KeyboardAppearanceDelegate>
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
    return [self->_viewModel numberOfContactInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ContactTableViewCell *cell = (ContactTableViewCell*)[tableView dequeueReusableCellWithIdentifier: CELL_REUSE_IDENTIFIER
                                                                              forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithFrame:CGRectZero];
    }

    ContactViewEntity *entity = [self->_viewModel contactAtIndex: indexPath];
    [cell updateCellWithContact:entity];
    
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self->_viewModel sectionIndexTitles];
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
    if (self.keyboardAppearanceDelegate && [self.keyboardAppearanceDelegate respondsToSelector:@selector(hideKeyboard)])
        [self.keyboardAppearanceDelegate hideKeyboard];
}


#pragma mark - Subclass methods
- (id<ContactViewModelProtocol>)viewModel {
    return _viewModel;
}

- (void)setupBaseViews {
    [self.view addSubview:_tableView];
    [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:CELL_REUSE_IDENTIFIER];
    
    _tableView.showsHorizontalScrollIndicator          = NO;
    _tableView.showsVerticalScrollIndicator            = NO;
    _tableView.separatorStyle                          = UITableViewScrollPositionNone;
    _tableView.backgroundColor                         = UIColor.whiteColor;
    _tableView.rowHeight                               = [ContactGlobalConfigure globalConfig].contactHeight;
    _tableView.delegate                                = self;
    _tableView.dataSource                              = self;
}

- (void)setupDatasets {
    
}

- (void)showErrorView:(ResponseViewType)type {
    ResponseInformationView * resView = [[ResponseInformationView alloc] initWithType:type];
    resView.keyboardAppearanceDelegate = self;
    [_tableView removeFromSuperview];
    [self.view addSubview:resView];
    resView.translatesAutoresizingMaskIntoConstraints = NO;
    [resView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active          =  YES;
    [resView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active        =  YES;
    [resView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active      =  YES;
    [resView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active    =  YES;
}

- (void)reloadTable {
    [_tableView reloadData];
}

- (void)reloadTableWithDeletedIndexes:(NSArray<NSIndexPath *> *)deletedIndexPaths addedIndexes:(NSArray<NSIndexPath *> *)addedIndexPaths {
    [_tableView reloadData];
}

- (void)removeCells:(NSArray<NSIndexPath *> *)indexPaths {
    DebugLog(@"[%@] begin remove cell from %ld indexs", LOG_MSG_HEADER, indexPaths.count);
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)contactHadRemoved:(NSIndexPath *)indexPath {
    ContactTableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
    [cell setSelect];
}

- (void)hideKeyboard {
    if (self.keyboardAppearanceDelegate && [self.keyboardAppearanceDelegate respondsToSelector:@selector(hideKeyboard)])
        [self.keyboardAppearanceDelegate hideKeyboard];
}
@end
#endif
