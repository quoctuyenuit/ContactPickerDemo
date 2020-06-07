//
//  MainViewController.m
//  ContactPicker
//
//  Created by Quốc Tuyến on 6/6/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import "MainViewController.h"
#import "ResponseInformationViewController.h"
#import "ContactViewController.h"
#import "ContactViewModelProtocol.h"

#import "ContactViewModel.h"
#import "ContactBus.h"
#import "ContactAdapter.h"

@interface MainViewController () {
    UIViewController * contentViewController;
    id<ContactViewModelProtocol> viewModel;
}
- (UIViewController *) loadContactViewController;
- (UIViewController *) loadPermissionDeniedViewController;
- (void) setupView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self->viewModel = [[ContactViewModel alloc] initWithBus: [[ContactBus alloc] initWithAdapter:[[ContactAdapter alloc] init]]];
    
    [self->viewModel requestPermission:^(BOOL granted) {
        if (granted) {
            self->contentViewController = [self loadContactViewController];
        } else {
            self->contentViewController = [self loadPermissionDeniedViewController];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupView];
        });
        
    }];
}



- (UIViewController *)loadContactViewController {
    self.view.backgroundColor = UIColor.whiteColor;
    return [ContactViewController instantiateWith:self->viewModel];
}

- (UIViewController *)loadPermissionDeniedViewController {
    return [ResponseInformationViewController instantiateWith:ResponseViewTypePermissionDenied];
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

@end
