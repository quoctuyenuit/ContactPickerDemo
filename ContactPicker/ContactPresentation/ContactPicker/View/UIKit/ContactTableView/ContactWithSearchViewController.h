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
#import "ContactCollectionCell.h"
#import "HorizontalListItemView.h"
#import "ContactBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactWithSearchViewController : ContactBaseController <UICollectionViewDelegate, UICollectionViewDataSource>
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
