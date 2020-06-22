//
//  TabbarOnTopViewController.h
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/21/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TabbarOnTopViewController : UIViewController
@property(nonatomic, readwrite) NSArray<UIViewController *>                 * viewControllers;
@property(nonatomic, readwrite) int                                           indexSelectedViewController;
@property(nullable, nonatomic,weak) id<UITabBarControllerDelegate>            delegate;

- (instancetype)initWithBarHeight:(CGFloat) height barColor:(UIColor *) color;
- (void)showViewControllerAtIndex:(NSUInteger) index;
@end

NS_ASSUME_NONNULL_END
