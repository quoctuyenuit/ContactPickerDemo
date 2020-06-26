//
//  MainViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "MainViewControllerUIkit.h"
#import "ResponseInformationView.h"
#import "ContactViewModelProtocol.h"
#import "ContactViewModel.h"
#import "ContactBus.h"
#import "ContactAdapter.h"
#import "Logging.h"

#import "ContactWithSearchTexture.h"
#import "ContactWithSearchComponentKit.h"
#import "ContactWithSearchUIKit.h"
#import "TabbarOnTopViewController.h"

#define DEBUG_JUST_UIKIT        0

#if !DEBUG_JUST_UIKIT
#define DEBUG_JUST_TEXTURE      0

#if !DEBUG_JUST_TEXTURE
#define DEBUG_JUST_COMPONENTKIT 0
#endif

#endif

@interface MainViewControllerUIkit () {
    UIViewController * contentViewController;
    ContactViewModel * viewModel;
}
- (UIViewController *) loadContactViewController;
- (UIViewController *) loadResponseInforView: (ResponseViewType) type;
@end

@implementation MainViewControllerUIkit

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self->viewModel = [[ContactViewModel alloc] initWithBus: [[ContactBus alloc] initWithAdapter:[[ContactAdapter alloc] init]]];
    
    __weak typeof(self) weakSelf = self;
    [self->viewModel requestPermission:^(BOOL granted, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                UIViewController * resVc = nil;
                if (granted) {
                    resVc = [strongSelf loadContactViewController];
                } else {
                    if (error.code == 1) {
                        resVc = [strongSelf loadResponseInforView:ResponseViewTypeSomethingWrong];
                        [Logging error:error.localizedDescription];
                    } else {
                        resVc = [strongSelf loadResponseInforView: ResponseViewTypePermissionDenied];
                    }
                }
                [strongSelf addChildViewController:resVc];
                [strongSelf.view addSubview:resVc.view];
                resVc.view.frame = strongSelf.view.bounds;
            }
        });
        
    }];
}


- (UIViewController *)loadResponseInforView:(ResponseViewType)type {
    UIView * v =[[ResponseInformationView alloc] initWithType:type];
    UIViewController * vc = [[UIViewController alloc] init];
    [vc.view addSubview:v];
    v.frame = vc.view.frame;
    return vc;
}

- (UIViewController *)loadContactViewController {
    ContactWithSearchUIKit * uikitContactVc = [[ContactWithSearchUIKit alloc] init];
    uikitContactVc.tabBarItem              = [[UITabBarItem alloc] initWithTitle:@"UIKit" image:[UIImage systemImageNamed:@"archivebox.fill"] tag:0];

#if DEBUG_JUST_UIKIT
    return uikitContactVc;
#endif

    ContactWithSearchTexture * textureContactVc = [[ContactWithSearchTexture alloc] init];
    textureContactVc.tabBarItem                     = [[UITabBarItem alloc] initWithTitle:@"Texture" image:[UIImage systemImageNamed:@"paperplane.fill"] tag:1];
    
#if DEBUG_JUST_TEXTURE
    return textureContactVc;
#endif

    ContactWithSearchComponentKit * componentVc   = [[ContactWithSearchComponentKit alloc] init];
    componentVc.tabBarItem                          = [[UITabBarItem alloc] initWithTitle:@"ComponentKit" image:[UIImage systemImageNamed:@"paperplane.fill"] tag:1];

#if DEBUG_JUST_COMPONENTKIT
    return componentVc;
#endif
    
    TabbarOnTopViewController *tabBarController = [[TabbarOnTopViewController alloc] initWithBarHeight:60 barColor:[UIColor appColor] viewControllers:@[uikitContactVc, textureContactVc, componentVc]];
    tabBarController.indexSelectedViewController = 0;
    self.view.backgroundColor = UIColor.whiteColor;
    
    return tabBarController;
}
@end
