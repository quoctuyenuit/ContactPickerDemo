//
//  ContactViewControllerTexture.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/16/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactViewControllerTexture.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "KeyboardAppearanceDelegate.h"
#import "ContactTableNodeController.h"
#import "SearchNode.h"
#import "ContactCollectionCellNode.h"
#import "HorizontalListNode.h"
#import "ResponseInformationViewController.h"

#define DEBUG_MODE              0
#define SEARCH_BAR_HEIGHT       56
#define SEARCH_PLACE_HOLDER     @"Tìm kiếm"
#define LOADING_MSG             @"Đang tải..."

@interface ContactViewControllerTexture()
- (void)setupEvents;
- (ASViewController<KeyboardAppearanceProtocol> *) loadContactTableViewController;
- (ASViewController<KeyboardAppearanceProtocol> *) loadFailLoadingContactViewController;
- (ASViewController<KeyboardAppearanceProtocol> *) loadEmptyViewController;
@end

@implementation ContactViewControllerTexture {
    BOOL                                              _isShowSelected;
    id<ContactViewModelProtocol>                      _viewModel;
    ASViewController<KeyboardAppearanceProtocol>    * _contentViewController;
    SearchNode                                      * _searchNode;
    ASDisplayNode                                   * _contentNode;
    HorizontalListNode                              * _contactSelectedView;
    HorizontalListNode                              * _contactSelectedKeyboardView;
    UIAlertController                               * _loadingController;
    
}
- (instancetype)initWithViewModel:(id<ContactViewModelProtocol>)viewModel {
    self = [super initWithNode:[[ASDisplayNode alloc] init]];
    if (self) {
        _viewModel                                  = viewModel;
        _searchNode                                 = [[SearchNode alloc] initWithHeight:SEARCH_BAR_HEIGHT];
        _searchNode.bar.placeholder                 = SEARCH_PLACE_HOLDER;
        _searchNode.bar.delegate                    = self;
        _searchNode.bar.searchTextField.delegate    = self;
        _contentNode                                = [[ASDisplayNode alloc] init];
        _contactSelectedView                        = [[HorizontalListNode alloc] init];
        _contactSelectedKeyboardView                = [[HorizontalListNode alloc] init];
        _isShowSelected                             = NO;
        _contactSelectedView.layer.shadowColor      = UIColor.grayColor.CGColor;
        _contactSelectedView.layer.shadowOpacity    = 1;
        _contactSelectedView.layer.shadowOffset     = CGSizeMake(1, 0);
        
        _contactSelectedView.collectionNode.delegate            = self;
        _contactSelectedView.collectionNode.dataSource          = self;
        _contactSelectedKeyboardView.collectionNode.delegate    = self;
        _contactSelectedKeyboardView.collectionNode.dataSource  = self;
        
        [self showSelectedContactsArea:NO];
        [_contactSelectedKeyboardView setFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 80)];
        
        _searchNode.bar.inputAccessoryView = _contactSelectedKeyboardView.view;
        
        self.node.automaticallyManagesSubnodes  = YES;
        [self layoutSubviews];
        
        [self setupEvents];
        
#if DEBUG_MODE
        _searchNode.backgroundColor             = UIColor.redColor;
        _contentNode.backgroundColor            = UIColor.greenColor;
        _contactSelectedView.backgroundColor    = UIColor.yellowColor;
#endif
        
    }
    return self;
}

#pragma mark - Life circle
- (void)loadView {
    [super loadView];
    _loadingController = [self createLoadingView:LOADING_MSG];
    [self loadContacts];
}

#pragma mark - Layout methods

- (void)layoutContentNode {
    __weak typeof(self) weakSelf = self;
    
    _contentNode.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) child:[strongSelf->_contentViewController.node styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.flexGrow = 10;
            }]];
        }
        return nil;
    };
    
    [_contentNode layoutIfNeeded];
}

- (void)layoutSubviews {
    __weak typeof(self) weakSelf = self;
    
    self.node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            return [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                           spacing:0
                                                    justifyContent:ASStackLayoutJustifyContentStart
                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                          children:
                    strongSelf->_isShowSelected ?
                    @[strongSelf->_searchNode,
                                                                      [strongSelf->_contentNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.flexGrow = 10;
                style.flexShrink = 10;
            }],
                                                                      [strongSelf->_contactSelectedView styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    style.flexShrink = 1;
                    style.preferredSize = CGSizeMake(strongSelf.node.calculatedSize.width, 80 + self.view.safeAreaInsets.bottom);
                }
            }]
                    ] :
                    
                    @[strongSelf->_searchNode,
                                                                              [strongSelf->_contentNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                        style.flexGrow = 10;
                        style.flexShrink = 10;
                    }]]
                    ];
        }
        NSAssert(NO, @"StrongSelf referrence had dealocated");
        return nil;
    };
}

#pragma mark - KeyboardAppearanceProtocol methods
- (void)hideKeyboard {
    [_searchNode.bar endEditing:YES];
}

#pragma mark - SearchbarDelegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _viewModel.searchObservable.value = searchText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_searchNode.bar endEditing:YES];
    return YES;
}

#pragma mark - ASCollectionDatasource methods
- (NSInteger)numberOfSectionsInCollectionNode:(ASCollectionNode *)collectionNode {
    return 1;
}

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section {
    return [_viewModel numberOfSelectedContacts];
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    ContactViewEntity * contact = [_viewModel selectedContactAtIndex:indexPath.item];
    ASCellNode *(^ASCellNodeBlock)(void) = ^ASCellNode * {
        ContactCollectionCellNode *  cellNode = [[ContactCollectionCellNode alloc] initWithContact:contact];
        cellNode.delegate = weakSelf;
        return cellNode;
    };
    return ASCellNodeBlock;
}

- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(55, 55));
}

#pragma mark - ContactCollectionCellDelegate methods
- (void)removeCell:(ContactViewEntity *)entity {
    [_viewModel removeSelectedContact:entity.identifier];
}

#pragma mark - Helper methods

- (void)loadContacts {
    [self presentViewController:_loadingController animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    [_viewModel loadContacts:^(BOOL isSuccess, NSError *error, NSUInteger numberOfContacts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                
                [strongSelf->_loadingController dismissViewControllerAnimated:YES completion:nil];
                if (!isSuccess) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    UIViewController<KeyboardAppearanceProtocol> * responseVC = [ResponseInformationViewController instantiateWith:ResponseViewTypeFailLoadingContact];
                    UIView * emptyView = responseVC.view;
                    [strongSelf->_contentNode.view addSubview:emptyView];
                    emptyView.frame = strongSelf->_contentNode.view.frame;
                    
                } else if (numberOfContacts == 0) {
                    
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    UIViewController<KeyboardAppearanceProtocol> * responseVC = [ResponseInformationViewController instantiateWith:ResponseViewTypeEmptyContact];
                    UIView * emptyView = responseVC.view;
                    [strongSelf->_contentNode.view addSubview:emptyView];
                    emptyView.frame = strongSelf->_contentNode.view.frame;
                    
                } else {
                    strongSelf->_contentViewController = [strongSelf loadContactTableViewController];
                    strongSelf->_contentViewController.keyboardAppearanceDelegate = strongSelf;
                    [strongSelf->_contentNode addSubnode:strongSelf->_contentViewController.node];
                    [strongSelf layoutContentNode];
                    [strongSelf->_contentNode setNeedsLayout];
                }
                
            }
        });
    }];
}

- (void) setupEvents {
    __weak typeof(self) weakSelf = self;
//    Listen contact had added observable
    [_viewModel.selectedContactAddedObservable binding:^(NSNumber * index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([index intValue] == 0) {
                [self showSelectedContactsArea:YES];
            }

            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[index intValue] inSection:0];
            [strongSelf->_contactSelectedView.collectionNode insertItemsAtIndexPaths:@[indexPath]];
            [strongSelf->_contactSelectedKeyboardView.collectionNode insertItemsAtIndexPaths:@[indexPath]];

            [strongSelf->_contactSelectedView.collectionNode scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            [strongSelf->_contactSelectedKeyboardView.collectionNode scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
    }];

//    Listen contact had removed observable
    [_viewModel.selectedContactRemoveObservable binding:^(NSNumber * index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([strongSelf->_viewModel numberOfSelectedContacts] == 0) {
                [self showSelectedContactsArea:NO];
            }

            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[index intValue] inSection:0];
            [strongSelf->_contactSelectedView.collectionNode deleteItemsAtIndexPaths:@[indexPath]];
            [strongSelf->_contactSelectedKeyboardView.collectionNode deleteItemsAtIndexPaths:@[indexPath]];
        }
    }];
}

- (ASViewController *)loadContactTableViewController {
    return [[ContactTableNodeController alloc] initWithViewModel:_viewModel];
}

- (ASViewController *)loadEmptyViewController {
    ASDisplayNode * node = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
        return [ResponseInformationViewController instantiateWith:ResponseViewTypeEmptyContact].view;
    }];
    return [[ASViewController alloc] initWithNode:node];
}

- (ASViewController *)loadFailLoadingContactViewController {
    ASDisplayNode * node = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
        return [ResponseInformationViewController instantiateWith:ResponseViewTypeFailLoadingContact].view;
    }];
    return [[ASViewController alloc] initWithNode:node];
}

- (void) contentTapGestureAction:(id) sender {
    [_searchNode.bar endEditing:YES];
}

- (UIAlertController *)createLoadingView: (NSString *) msg {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
    alert.view.tintColor = UIColor.blackColor;
    UIActivityIndicatorView * loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    [loadingIndicator startAnimating];
    [alert.view addSubview:loadingIndicator];
    return alert;
}

- (void)showSelectedContactsArea: (BOOL) isShow {
    __weak typeof(self) weakSelf = self;
    _isShowSelected = isShow;
    [UIView animateWithDuration:0.3 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->_contactSelectedView.alpha = isShow ? 1 : 0;
            strongSelf->_contactSelectedKeyboardView.alpha = isShow ? 1 : 0;
        }
    } completion:^(BOOL finished) {
        [weakSelf.node setNeedsLayout];
    }];
}

@end
