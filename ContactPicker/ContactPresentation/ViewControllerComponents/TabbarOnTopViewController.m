//
//  TabbarOnTopViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/21/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "TabbarOnTopViewController.h"
#import "Utilities.h"
#import "TabbarOnTopItemView.h"
#import "TabbarOnTopItemDelegate.h"
#import "ContactDefine.h"

#define DEFAULT_BARITEM_WIDTH       150
#define DEBUG_MODE                  0
#define NORMAL_COLOR                UIColor.grayColor

@interface TabbarOnTopViewController () <TabbarOnTopItemDelegate, UIScrollViewDelegate>
- (void)setupViews;
- (void)showItemBar:(NSUInteger) index;
@end

@implementation TabbarOnTopViewController {
    CGFloat                   _barHeight;
    UIColor                 * _barColor;
    UIView                  * _barBoundView;
    UIScrollView            * _barScroll;
    UIScrollView            * _contentScroll;
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
        _contentScroll      = [[UIScrollView alloc] init];
        
        _contentScroll.showsVerticalScrollIndicator     = NO;
        _contentScroll.showsHorizontalScrollIndicator   = NO;
        
        _contentScroll.delegate = self;
        
        [_contentScroll setPagingEnabled:YES];
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
    weak_self
    [UIView animateWithDuration:0.3 animations:^{
        strong_self
        if (strongSelf) {
            [strongSelf showItemBar:index];
            
            CGFloat width   = self.view.bounds.size.width;
            CGFloat offsetX = index * width;
            [strongSelf->_contentScroll scrollRectToVisible:CGRectMake(offsetX, 0, width, self.view.bounds.size.height) animated:YES];
        }
    }];
}

#pragma mark - Helper methods
- (void)showItemBar:(NSUInteger)index {
    for (TabbarOnTopItemView * barItem in _items) {
        barItem.isHighLight = NO;
    }
    [_items objectAtIndex:index].isHighLight = YES;
    
    if (_viewControllers.count > 3) {
        CGFloat width   = DEFAULT_BARITEM_WIDTH;
        CGFloat offsetX = index * width;
        [_barScroll scrollRectToVisible:CGRectMake(offsetX, 0, width, _barHeight) animated:YES];
    }
}

- (void)setupViews {
    [self.view addSubview:_barBoundView];
    [self.view addSubview:_contentScroll];
    [_contentScroll addSubview:_contentView];
    
    _barBoundView.translatesAutoresizingMaskIntoConstraints     = NO;
    _contentView.translatesAutoresizingMaskIntoConstraints      = NO;
    _contentScroll.translatesAutoresizingMaskIntoConstraints    = NO;
    
    [_barBoundView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active    = YES;
    [_barBoundView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active                      = YES;
    [_barBoundView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active                    = YES;
    [_barBoundView.heightAnchor constraintEqualToConstant:_barHeight].active                            = YES;
    
    [_contentScroll.topAnchor constraintEqualToAnchor:_barBoundView.bottomAnchor].active   = YES;
    [_contentScroll.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active        = YES;
    [_contentScroll.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active      = YES;
    [_contentScroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active    = YES;
    
    [_contentView.topAnchor constraintEqualToAnchor:_contentScroll.topAnchor].active          = YES;
    [_contentView.leftAnchor constraintEqualToAnchor:_contentScroll.leftAnchor].active        = YES;
    [_contentView.rightAnchor constraintEqualToAnchor:_contentScroll.rightAnchor].active      = YES;
    [_contentView.bottomAnchor constraintEqualToAnchor:_contentScroll.bottomAnchor].active    = YES;
    [_contentView.heightAnchor constraintEqualToAnchor:_contentScroll.heightAnchor].active    = YES;
    
    UIView * tabItemView = _barBoundView;
    CGFloat tabItemWidth = self.view.bounds.size.width/self.viewControllers.count;
    
    if (self.viewControllers.count > 3) {
        tabItemView     = [[UIView alloc] init]; // Scroll content view
        _barScroll      = [[UIScrollView alloc] init];
        tabItemWidth    = DEFAULT_BARITEM_WIDTH;
        
        _barScroll.showsVerticalScrollIndicator     = NO;
        _barScroll.showsHorizontalScrollIndicator   = NO;

        [_barScroll setPagingEnabled:YES];
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
    NSLayoutXAxisAnchor * leftContentAnchor = _contentView.leftAnchor;
    int vcIndex = 0;

    for (UIViewController * vc in self.viewControllers) {
        TabbarOnTopItemView * tabItem = [[TabbarOnTopItemView alloc] initWithTitle:vc.tabBarItem.title
                                                                             image:vc.tabBarItem.image];
        tabItem.delegate    = self;
        tabItem.itemColor   = _highlightColor;
        [_items addObject:tabItem];
        
        [tabItemView addSubview:tabItem];
        [_contentView addSubview:vc.view];
        [self addChildViewController:vc];
        
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        tabItem.translatesAutoresizingMaskIntoConstraints = NO;
        
        [vc.view.topAnchor constraintEqualToAnchor:_contentView.topAnchor].active           = YES;
        [vc.view.leftAnchor constraintEqualToAnchor:leftContentAnchor].active               = YES;
        [vc.view.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor].active     = YES;
        [vc.view.widthAnchor constraintEqualToConstant:self.view.bounds.size.width].active  = YES;

        [tabItem.topAnchor constraintEqualToAnchor:tabItemView.topAnchor].active        = YES;
        [tabItem.leftAnchor constraintEqualToAnchor:leftAnchor].active                  = YES;
        [tabItem.bottomAnchor constraintEqualToAnchor:tabItemView.bottomAnchor].active  = YES;
        [tabItem.widthAnchor constraintEqualToConstant:tabItemWidth].active             = YES;

        if (vcIndex == self.viewControllers.count - 1) {
            [tabItem.rightAnchor constraintEqualToAnchor:tabItemView.rightAnchor].active = YES;
            [vc.view.rightAnchor constraintEqualToAnchor:_contentView.rightAnchor].active      = YES;
        }

        vcIndex++;
        leftAnchor          = tabItem.rightAnchor;
        leftContentAnchor   = vc.view.rightAnchor;
    }
    self.viewControllers[self.indexSelectedViewController].view.alpha = 1;
    _items[self.indexSelectedViewController].isHighLight              = YES;
    
#if DEBUG_MODE
    _barBoundView.backgroundColor           = UIColor.redColor;
    _contentScroll.backgroundColor          = UIColor.yellowColor;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat page = (scrollView.contentOffset.x + (0.5f * viewWidth)) / viewWidth;
    
    _indexSelectedViewController = (int)page;
    [self showItemBar:_indexSelectedViewController];
}

@end
