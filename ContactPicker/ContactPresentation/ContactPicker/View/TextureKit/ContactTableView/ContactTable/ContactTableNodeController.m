//
//  ContactTableNodeController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/15/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactTableNodeController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "ContactViewEntity.h"
#import "ContactTableCellNode.h"

@interface ContactTableNodeController () <ASTableDelegate, ASTableDataSource> {
    id<ContactViewModelProtocol> _viewModel;
}
@property (nonatomic, strong) ASTableNode * tableNode;
@end

@implementation ContactTableNodeController
@synthesize keyboardAppearanceDelegate;

#pragma mark - Lifecycle

- (instancetype) initWithModel: (ContactViewModel *) viewModel {
    self->_tableNode = [[ASTableNode alloc] init];
    self->_viewModel = viewModel;
    self = [super initWithNode:self->_tableNode];
    if (self) {
        self->_tableNode.delegate = self;
        self->_tableNode.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    
    [self->_viewModel.contactBookObservable binding:^(NSNumber * number) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf->_tableNode reloadData];
        });
        }
    }];
    
    [self->_viewModel.searchObservable binding:^(NSString * searchText) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf->_viewModel searchContactWithKeyName:searchText];
        }
    }];
    
    [self->_viewModel.dataSourceNeedReloadObservable binding:^(NSNumber * flag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf.tableNode reloadData];
            }
        });
    }];
    
    [self->_viewModel.contactHadAddedObservable binding:^(NSArray<NSIndexPath *> * updatedIndexPaths) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                @try {
                    NSLog(@"contact have %d", [self->_viewModel numberOfContactInSection:26]);
                    [strongSelf.tableNode insertRowsAtIndexPaths:updatedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                } @catch (NSException *exception) {
                    [strongSelf.tableNode reloadData];
                }
            }
        });
    }];
    
    [self->_viewModel.cellNeedRemoveSelectedObservable binding:^(NSIndexPath * indexPath) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            ContactTableCellNode * cell = [strongSelf->_tableNode nodeForRowAtIndexPath:indexPath];
            [cell setSelect];
        }
    }];
    
//    [self->_viewModel loadContacts:^(BOOL isSuccess, NSError * error, int numberOfContacts) {
//        NSLog(@"First load have %d contacts", numberOfContacts);
//    }];
    
}

- (void)loadView {
    [super loadView];
    self->_tableNode.view.showsHorizontalScrollIndicator = NO;
    self->_tableNode.view.showsVerticalScrollIndicator = NO;
    self->_tableNode.view.separatorStyle = UITableViewScrollPositionNone;
    self->_tableNode.backgroundColor = UIColor.whiteColor;
    self->_tableNode.view.rowHeight = 60;
}

#pragma mark - ASTableDatasource methods
- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return [self->_viewModel numberOfSection];
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return [self->_viewModel numberOfContactInSection:section];
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactViewEntity * contact = [self->_viewModel contactAtIndex:indexPath];
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode * {
        return [[ContactTableCellNode alloc] initWithContact:contact];
    };
    return ASCellNodeBlock;
}

- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableNode deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactTableCellNode * cell = (ContactTableCellNode *)[tableNode nodeForRowAtIndexPath:indexPath];
    [cell setSelect];
    
    [self->_viewModel selectectContactAtIndex:indexPath];
    
    [self.keyboardAppearanceDelegate hideKeyboard];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self->_viewModel getAllSectionNames];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self->_viewModel numberOfContactInSection:section] > 0 ? [self->_viewModel titleForHeaderInSection:section] : nil;
}
@end
