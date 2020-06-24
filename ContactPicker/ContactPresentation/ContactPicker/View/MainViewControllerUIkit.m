//
//  MainViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "MainViewControllerUIkit.h"
#import "ResponseInformationViewController.h"
#import "ContactWithSearchViewController.h"
#import "ContactViewModelProtocol.h"

#import "ContactViewModel.h"
#import "ContactBus.h"
#import "ContactAdapter.h"
#import "Logging.h"

#import "ContactViewControllerTexture.h"
#import "ContactTableNodeController.h"
#import "ContactTableComponentController.h"

#import "TabbarOnTopViewController.h"

#define DEBUG_COMPONENTKIT  1



#if DEBUG_COMPONENTKIT
#import "WildeGuessCollectionViewController.h"
#endif



@interface MainViewControllerUIkit () <UITabBarControllerDelegate> {
    UIViewController * contentViewController;
    ContactViewModel * viewModel;
}
- (UIViewController *) loadContactViewController;
- (UIViewController *) loadResponseInforView: (ResponseViewType) type;
- (void) setupView;
@end

@implementation MainViewControllerUIkit

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    return [ResponseInformationViewController instantiateWith:type];
}

- (UIViewController *)loadContactViewController {
    ContactWithSearchViewController * uikitContactVc = [[ContactWithSearchViewController alloc] init];
    uikitContactVc.tabBarItem              = [[UITabBarItem alloc] initWithTitle:@"UIKit" image:[UIImage systemImageNamed:@"archivebox.fill"] tag:0];


    ContactViewControllerTexture * textureContactVc = [[ContactViewControllerTexture alloc] init];
    textureContactVc.tabBarItem                     = [[UITabBarItem alloc] initWithTitle:@"Texture" image:[UIImage systemImageNamed:@"paperplane.fill"] tag:1];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];

    ContactTableComponentController * componentVc   = [[ContactTableComponentController alloc] initWithCollectionViewLayout:flowLayout];
    componentVc.tabBarItem                          = [[UITabBarItem alloc] initWithTitle:@"ComponentKit" image:[UIImage systemImageNamed:@"paperplane.fill"] tag:1];

//    UITabBarController *tabBarController         = [[UITabBarController alloc] init];
    TabbarOnTopViewController *tabBarController = [[TabbarOnTopViewController alloc] initWithBarHeight:60 barColor:[UIColor appColor] viewControllers:@[uikitContactVc, textureContactVc, componentVc]];
//    tabBarController.viewControllers             = ;
//    tabBarController.selectedViewController      = uikitContactVc;
    tabBarController.indexSelectedViewController = 0;
    tabBarController.delegate                    = self;
    [[UITabBar appearance] setTintColor:[UIColor appColor]];

    
    
    

    self.view.backgroundColor = UIColor.whiteColor;
    
#if DEBUG_COMPONENTKIT
    WildeGuessCollectionViewController *viewController = [[WildeGuessCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    
    return componentVc;
    
#endif
    
    return tabBarController;
}

- (void)setupView {
    [self addChildViewController:self->contentViewController];
    [self.view addSubview:self->contentViewController.view];
    
    self->contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self->contentViewController.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [self->contentViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self->contentViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self->contentViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//    if ([viewController conformsToProtocol:@protocol(PhotoFeedControllerProtocol)]) {
//          // FIXME: the dataModel does not currently handle clearing data during loading properly
//    //      [(id <PhotoFeedControllerProtocol>)rootViewController resetAllData];
//        }
}

@end
