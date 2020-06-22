//
//  TabbarOnTopViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/21/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "TabbarOnTopViewController.h"
#import "UIButtonExtension.h"
#import "Utilities.h"
#import "TabbarOnTopItemView.h"
#import "TabbarOnTopItemDelegate.h"

#define DEFAULT_BARITEM_WIDTH       100
#define DEBUG_MODE                  0
#define NORMAL_COLOR                UIColor.grayColor

@interface TabbarOnTopViewController () <TabbarOnTopItemDelegate>
- (void)setupViews;
@end

@implementation TabbarOnTopViewController {
    CGFloat                   _barHeight;
    UIColor                 * _barColor;
    UIView                  * _barBoundView;
    UIScrollView            * _barScroll;
    UIView                  * _contentView;
    UIColor                 * _highlightColor;
    UIColor                 * _normalColor;
    
    NSMutableArray<TabbarOnTopItemView *> * _items;
}

- (instancetype)initWithBarHeight:(CGFloat)height barColor:(UIColor *)color viewControllers:(NSArray<UIViewController *> *) viewController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _barHeight          = height;
        _highlightColor     = color;
        _normalColor        = NORMAL_COLOR;
        _barBoundView       = [[UIView alloc] init];
        _contentView        = [[UIView alloc] init];
        _items              = [[NSMutableArray alloc] init];
        _viewControllers    = viewController;
        
//        [_contentView dropShadow];
        
        UISwipeGestureRecognizer * leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSlideAction:)];
        leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        
        UISwipeGestureRecognizer * rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSlideAction:)];
        rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self.view addGestureRecognizer:leftSwipeGesture];
        [self.view addGestureRecognizer:rightSwipeGesture];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

#pragma mark - Public methods
- (void)setIndexSelectedViewController:(NSUInteger)indexSelectedViewController {
    if (indexSelectedViewController >= self.viewControllers.count)
        _indexSelectedViewController = 0;
    else
        _indexSelectedViewController = indexSelectedViewController;
}

- (void)showViewControllerAtIndex:(NSUInteger)index {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            for (TabbarOnTopItemView * barItem in strongSelf->_items) {
                barItem.isHighLight = NO;
            }
            
            for (UIViewController * vc in strongSelf.viewControllers) {
                vc.view.alpha = 0;
            }
            
            
            [strongSelf->_items objectAtIndex:index].isHighLight = YES;
            [strongSelf.viewControllers objectAtIndex:index].view.alpha = 1;
        }
    }];
    
    
}

#pragma mark - Helper methods
- (void)setupViews {
    [self.view addSubview:_barBoundView];
    [self.view addSubview:_contentView];
    
    _barBoundView.translatesAutoresizingMaskIntoConstraints     = NO;
    _contentView.translatesAutoresizingMaskIntoConstraints      = NO;
    
    [_barBoundView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active    = YES;
    [_barBoundView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active                      = YES;
    [_barBoundView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active                    = YES;
    [_barBoundView.heightAnchor constraintEqualToConstant:_barHeight].active                            = YES;
    
    [_contentView.topAnchor constraintEqualToAnchor:_barBoundView.bottomAnchor].active   = YES;
    [_contentView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active        = YES;
    [_contentView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active      = YES;
    [_contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active    = YES;
    
    UIView * tabItemView = _barBoundView;
    CGFloat tabItemWidth = self.view.bounds.size.width/self.viewControllers.count;
    
    if (self.viewControllers.count > 3) {
        tabItemView = [[UIView alloc] init]; // Scroll content view
        tabItemWidth = DEFAULT_BARITEM_WIDTH;

        [_barBoundView addSubview:_barScroll];
        [_barScroll addSubview:tabItemView];
        _barScroll.translatesAutoresizingMaskIntoConstraints    = NO;
        tabItemView.translatesAutoresizingMaskIntoConstraints   = NO;
        
        [_barScroll.topAnchor constraintEqualToAnchor:_barBoundView.topAnchor].active       = YES;
        [_barScroll.rightAnchor constraintEqualToAnchor:_barBoundView.rightAnchor].active   = YES;
        [_barScroll.leftAnchor constraintEqualToAnchor:_barBoundView.leftAnchor].active     = YES;
        [_barScroll.bottomAnchor constraintEqualToAnchor:_barBoundView.bottomAnchor].active = YES;

        [tabItemView.topAnchor constraintEqualToAnchor:_barScroll.topAnchor].active         = YES;
        [tabItemView.bottomAnchor constraintEqualToAnchor:_barScroll.bottomAnchor].active   = YES;
        [tabItemView.leftAnchor constraintEqualToAnchor:_barScroll.leftAnchor].active       = YES;
        [tabItemView.rightAnchor constraintEqualToAnchor:_barScroll.rightAnchor].active     = YES;
        [tabItemView.heightAnchor constraintEqualToAnchor:_barScroll.heightAnchor].active   = YES;
    }

    NSLayoutXAxisAnchor * leftAnchor = tabItemView.leftAnchor;
    int vcIndex = 0;

    for (UIViewController * vc in self.viewControllers) {
        [_contentView addSubview:vc.view];
        [self addChildViewController:vc];
        vc.view.alpha = 0;

        vc.view.translatesAutoresizingMaskIntoConstraints = NO;

        [vc.view.topAnchor constraintEqualToAnchor:_contentView.topAnchor].active   = YES;
        [vc.view.leftAnchor constraintEqualToAnchor:_contentView.leftAnchor].active        = YES;
        [vc.view.rightAnchor constraintEqualToAnchor:_contentView.rightAnchor].active      = YES;
        [vc.view.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor].active    = YES;

        
        TabbarOnTopItemView * tabItem = [[TabbarOnTopItemView alloc] initWithTitle:vc.tabBarItem.title image:vc.tabBarItem.image];
        tabItem.delegate = self;
        tabItem.itemColor = _highlightColor;
        [_items addObject:tabItem];
        
        [tabItemView addSubview:tabItem];
        tabItem.translatesAutoresizingMaskIntoConstraints = NO;

        [tabItem.topAnchor constraintEqualToAnchor:tabItemView.topAnchor].active        = YES;
        [tabItem.leftAnchor constraintEqualToAnchor:leftAnchor].active                  = YES;
        [tabItem.bottomAnchor constraintEqualToAnchor:tabItemView.bottomAnchor].active  = YES;
        [tabItem.widthAnchor constraintEqualToConstant:tabItemWidth].active             = YES;

        if (vcIndex == self.viewControllers.count - 1) {
            [tabItem.rightAnchor constraintEqualToAnchor:tabItemView.rightAnchor].active = YES;
        }

        vcIndex++;
        leftAnchor = tabItem.rightAnchor;
    }
    self.viewControllers[self.indexSelectedViewController].view.alpha = 1;
    _items[self.indexSelectedViewController].isHighLight              = YES;
    
#if DEBUG_MODE
    _barBoundView.backgroundColor           = UIColor.redColor;
    _contentView.backgroundColor            = UIColor.greenColor;
#endif
}

#pragma mark - TabbarOnTopItemDelegate methods
- (void)didTapOnItem:(TabbarOnTopItemView *)item state:(BOOL)isHighLight {
    
    NSUInteger index = [_items indexOfObject:item];
    
    if (index == _indexSelectedViewController) {
        return;
    } else {
        _indexSelectedViewController = index;
    }
    
    [self showViewControllerAtIndex:index];
}

- (void)leftSlideAction:(UISwipeGestureRecognizer *) gesture {
     if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
         _indexSelectedViewController++;
         if (_indexSelectedViewController >= _viewControllers.count)
             _indexSelectedViewController = 0;
     } else {
         _indexSelectedViewController--;
         if (_indexSelectedViewController < 0)
             _indexSelectedViewController = _viewControllers.count - 1;
     }
    
    [self showViewControllerAtIndex:_indexSelectedViewController];
    
    
}

@end
