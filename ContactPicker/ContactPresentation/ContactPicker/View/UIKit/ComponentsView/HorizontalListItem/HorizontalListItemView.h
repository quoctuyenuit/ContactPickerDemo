//
//  HorizontalListItemView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/10/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface HorizontalListItemView : UIView {
    UIView            *_mainContentView;
    UIButton          *_button;
}
@property (strong, nonatomic) UICollectionView  *collectionView;

@end

NS_ASSUME_NONNULL_END
