//
//  MainViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "ContactMainViewController.h"
#import "ResponseInformationView.h"
#import "ContactViewModelProtocol.h"
#import "ContactViewModel.h"
#import "ContactBusinessLayer.h"
#import "ContactAdapter.h"
#import "ContactDefine.h"

#import "ContactWithSearchTexture.h"
#import "ContactWithSearchComponentKit.h"
#import "ContactWithSearchUIKit.h"
#import "TabbarOnTopViewController.h"


#define UIKIT_TITLE         @"UIkit"
#define TEXTURE_TITLE       @"Texture"
#define COMPONENTKIT_TITLE  @"ComponentKit"

#define UIKIT_ICO_NAME          @"archivebox.fill"
#define TEXTURE_ICO_NAME        @"paperplane.fill"
#define COMPONENTKIT_ICO_NAME   @"paperplane.fill"

@interface ContactMainViewController () {
    UIViewController * _contentViewController;
    ContactViewModel * viewModel;
}
- (void) setupViews;
- (UIViewController *) loadContactViewController;
- (UIViewController *) loadResponseInforView: (ResponseViewType) type;
@end

@implementation ContactMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self->viewModel = [[ContactViewModel alloc] initWithBus: [[ContactBusinessLayer alloc] initWithAdapter:[[ContactAdapter alloc] init]]];
    
    __weak typeof(self) weakSelf = self;
    [self->viewModel requestPermission:^(BOOL granted, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (granted) {
                    strongSelf->_contentViewController = [strongSelf loadContactViewController];
                } else {
                    if (error.code == UNSUPPORTED_ERROR_CODE) {
                        strongSelf->_contentViewController = [strongSelf loadResponseInforView:ResponseViewTypeSomethingWrong];
                        DebugLog(@"%@", error.localizedDescription);
                    } else {
                        strongSelf->_contentViewController = [strongSelf loadResponseInforView: ResponseViewTypePermissionDenied];
                    }
                }
                [strongSelf setupViews];
            }
        });
        
    }];
}

- (void)setupViews {
    [self addChildViewController:_contentViewController];
    [self.view addSubview:_contentViewController.view];
    
    _contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentViewController.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [_contentViewController.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active        = YES;
    [_contentViewController.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active      = YES;
    [_contentViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active    = YES;
}


- (UIViewController *)loadResponseInforView:(ResponseViewType)type {
    UIView * v =[[ResponseInformationView alloc] initWithType:type];
    UIViewController * vc = [[UIViewController alloc] init];
    [vc.view addSubview:v];
    v.frame = vc.view.frame;
    return vc;
}

- (UIViewController *)loadContactViewController {
    NSMutableArray * viewControllers = [[NSMutableArray alloc] init];
    
#if BUILD_UIKIT
    ContactWithSearchUIKit * uikitContactVc = [[ContactWithSearchUIKit alloc] init];
    uikitContactVc.tabBarItem              = [[UITabBarItem alloc] initWithTitle:UIKIT_TITLE image:[UIImage systemImageNamed:UIKIT_ICO_NAME] tag:0];
    [viewControllers addObject:uikitContactVc];
#endif
    
#if BUILD_TEXTURE
    ContactWithSearchTexture * textureContactVc = [[ContactWithSearchTexture alloc] init];
    textureContactVc.tabBarItem                     = [[UITabBarItem alloc] initWithTitle:TEXTURE_TITLE image:[UIImage systemImageNamed:TEXTURE_ICO_NAME] tag:1];
    [viewControllers addObject:textureContactVc];
#endif
    
#if BUILD_COMPONENTKIT
    ContactWithSearchComponentKit * componentVc   = [[ContactWithSearchComponentKit alloc] init];
    componentVc.tabBarItem                          = [[UITabBarItem alloc] initWithTitle:COMPONENTKIT_TITLE image:[UIImage systemImageNamed:COMPONENTKIT_ICO_NAME] tag:1];
    [viewControllers addObject:componentVc];
#endif
    
    TabbarOnTopViewController *tabBarController = [[TabbarOnTopViewController alloc] initWithBarHeight:60 barColor:[UIColor appColor] viewControllers:viewControllers];
    tabBarController.indexSelectedViewController = 0;
    self.view.backgroundColor = UIColor.whiteColor;
    
    return tabBarController;
}
@end
