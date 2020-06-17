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
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *button;


@end

NS_ASSUME_NONNULL_END
