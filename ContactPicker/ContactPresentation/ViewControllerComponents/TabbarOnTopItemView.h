//
//  TabbarOnTopItemView.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/22/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabbarOnTopItemDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TabbarOnTopItemView : UIView
@property(nonatomic, readwrite) UILabel         * label;
@property(nonatomic, readwrite) UIImageView     * imageView;
@property(nonatomic, readwrite) BOOL              isHighLight;
@property(nonatomic, readwrite) UIColor         * itemColor;

@property(weak, readwrite) id<TabbarOnTopItemDelegate> delegate;

- (instancetype)initWithTitle:(NSString *) title image:(UIImage *) image;
@end

NS_ASSUME_NONNULL_END
