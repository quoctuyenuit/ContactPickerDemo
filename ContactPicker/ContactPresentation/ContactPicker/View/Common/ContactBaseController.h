//
//  ContactBaseController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/21/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContactControllerProtocol.h"
#import "ContactViewModelProtocol.h"
#import "KeyboardAppearanceDelegate.h"
#import "ContactCollectionCellProtocol.h"
#import "ResponseInformationViewController.h"

NS_ASSUME_NONNULL_BEGIN

#define SEARCH_BAR_HEIGHT           56

@interface ContactBaseController : ASViewController <ContactControllerProtocol, KeyboardAppearanceDelegate, ContactCollectionCellDelegate>
@property(nonatomic, readwrite) id<ContactViewModelProtocol>          viewModel;
@property(nonatomic, readwrite) UISearchBar                         * searchBar;
@property(nonatomic, readwrite) UIView                              * contentView;
- (ResponseInformationViewController *)loadResponseInforView:(ResponseViewType)type;
- (void)showSelectedContactsArea:(BOOL) isShow;
- (CGSize)selectedItemSize;
- (void)addSelectedContact:(NSIndexPath *) indexPath;
- (void)removeSelectedContact:(NSIndexPath *) indexPath;
- (void)loadContactTable;
- (void)loadContact;
@end

NS_ASSUME_NONNULL_END
