//
//  MainViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "MainViewControllerUIkit.h"
#import "ResponseInformationViewController.h"
#import "ContactViewController.h"
#import "ContactViewModelProtocol.h"

#import "ContactViewModel.h"
#import "ContactBus.h"
#import "ContactAdapter.h"
#import "Logging.h"

#import "ContactViewControllerTexture.h"
#import "ContactTableNodeController.h"

@interface MainViewControllerUIkit () <UITabBarControllerDelegate> {
    UIViewController * contentViewController;
    id<ContactViewModelProtocol> viewModel;
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
    
    [self->viewModel requestPermission:^(BOOL granted, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self->contentViewController = [self loadContactViewController];
//                self->contentViewController = [[ContactViewControllerTexture alloc] initWithViewModel:self->viewModel];
            } else {
                if (error.code == 1) {
                    self->contentViewController = [self loadResponseInforView:ResponseViewTypeSomethingWrong];
                    [Logging error:error.localizedDescription];
                } else {
                    self->contentViewController = [self loadResponseInforView: ResponseViewTypePermissionDenied];
                }
            }
            
            [self setupView];
        });
        
    }];
}


- (UIViewController *)loadResponseInforView:(ResponseViewType)type {
    return [ResponseInformationViewController instantiateWith:type];
}

- (UIViewController *)loadContactViewController {
    ContactViewController * uikitContactVc = [ContactViewController instantiateWith:self->viewModel];
    uikitContactVc.tabBarItem              = [[UITabBarItem alloc] initWithTitle:@"UIKit" image:[UIImage systemImageNamed:@"archivebox.fill"] tag:0];
    
    
    ContactViewControllerTexture * textureContactVc = [[ContactViewControllerTexture alloc] initWithViewModel:self->viewModel];
    textureContactVc.tabBarItem                     = [[UITabBarItem alloc] initWithTitle:@"Texture" image:[UIImage systemImageNamed:@"paperplane.fill"] tag:0];
    
    UITabBarController *tabBarController         = [[UITabBarController alloc] init];
    tabBarController.viewControllers             = @[uikitContactVc, textureContactVc];
    tabBarController.selectedViewController      = uikitContactVc;
    tabBarController.delegate                    = self;
    [[UITabBar appearance] setTintColor:[UIColor appColor]];
    
    self.view.backgroundColor = UIColor.whiteColor;
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
    if ([viewController conformsToProtocol:@protocol(PhotoFeedControllerProtocol)]) {
          // FIXME: the dataModel does not currently handle clearing data during loading properly
    //      [(id <PhotoFeedControllerProtocol>)rootViewController resetAllData];
        }
}

@end
