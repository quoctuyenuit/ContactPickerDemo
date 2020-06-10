//
//  HorizontalListItemView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface HorizontalListItemView : UIView
@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;

- (void) reloadData;
@end

@protocol HorizontalListItemViewDataSource <NSObject>

- (NSInteger) numberOfItems: (HorizontalListItemView *) listView;
//- (void) itemForIndex: (HorizontalListItemView *) listView

@end

NS_ASSUME_NONNULL_END
