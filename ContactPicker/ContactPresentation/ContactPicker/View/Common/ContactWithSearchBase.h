//
//  ContactBaseController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/21/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactViewModelProtocol.h"
#import "KeyboardAppearanceDelegate.h"
#import "ContactCollectionCellProtocol.h"
#import "ResponseInformationView.h"
#import "HorizontalListItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define SEARCH_BAR_HEIGHT           56

@interface ContactWithSearchBase : ASViewController <KeyboardAppearanceDelegate, ContactCollectionCellDelegate>
@property(nonatomic, readwrite) id<ContactViewModelProtocol>          viewModel;
@property(nonatomic, readwrite) UISearchBar                         * searchBar;
@property(nonatomic, readwrite) id<HorizontalListItemProtocol>        selectedContactView;
@property(nonatomic, readwrite) id<HorizontalListItemProtocol>        keyboardSearchbarView;

- (ResponseInformationView *)loadResponseInforView:(ResponseViewType)type;
- (void)loadContact;
- (CGSize)selectedItemSize;
- (void)showSelectedContactsArea:(BOOL) isShow;
@end

NS_ASSUME_NONNULL_END
