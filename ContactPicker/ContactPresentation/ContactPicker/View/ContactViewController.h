//
//  ContactViewController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewModelProtocol.h"
#import "KeyboardAppearanceDelegate.h"
#import "ContactTableDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewController : UIViewController <UISearchBarDelegate, UITextFieldDelegate, KeyboardAppearanceDelegate, ContactTableDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *contactSelectedArea;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
+ (ContactViewController *) instantiateWith: (id<ContactViewModelProtocol>) viewModel;
@end

NS_ASSUME_NONNULL_END
