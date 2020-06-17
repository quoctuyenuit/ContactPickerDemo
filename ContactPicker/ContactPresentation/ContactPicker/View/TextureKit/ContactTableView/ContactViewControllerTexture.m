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

#define DEBUG_MODE              0
#define SEARCH_BAR_HEIGHT       56
#define SEARCH_PLACE_HOLDER     @"Tìm kiếm"

@implementation ContactViewControllerTexture {
    id<ContactViewModelProtocol>                      _viewModel;
    ASViewController<KeyboardAppearanceProtocol>    * _contentViewController;
    SearchNode                                      * _searchNode;
    ASDisplayNode                                   * _contentNode;
    
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
        
        self.node.automaticallyManagesSubnodes  = YES;
        [self layoutSubviews];
        
        __weak typeof(self) weakSelf = self;
        [self->_viewModel loadContacts:^(BOOL isSuccess, NSError *error, int numberOfContacts) {
            if (isSuccess) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf) {
                        strongSelf->_contentViewController = [[ContactTableNodeController alloc] initWithModel:strongSelf->_viewModel];
                        [strongSelf->_contentNode addSubnode:strongSelf->_contentViewController.node];
                        [strongSelf.node layoutIfNeeded];
                    }
                });
            }
        }];
        
#if DEBUG_MODE
        _searchNode.backgroundColor         = UIColor.redColor;
        _contentNode.backgroundColor        = UIColor.greenColor;
#endif
        
    }
    return self;
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
                                                          children: @[strongSelf->_searchNode,
                                                                      [strongSelf->_contentNode styledWithBlock:^(__kindof ASLayoutElementStyle * _Nonnull style) {
                style.flexGrow = 10;
            }]
                                                          ]];
        }
        NSAssert(NO, @"StrongSelf referrence had dealocated");
        return nil;
    };
}

#pragma mark - KeyboardAppearanceProtocol delegate
- (void)hideKeyboard {
    [_searchNode.bar endEditing:YES];
}

#pragma mark - Searchbar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _viewModel.searchObservable.value = searchText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_searchNode.bar endEditing:YES];
    return YES;
}

@end
