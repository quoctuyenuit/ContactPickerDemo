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

#import "Logging.h"

@interface MainViewController () {
    UIViewController * contentViewController;
    id<ContactViewModelProtocol> viewModel;
}
- (UIViewController *) loadContactViewController;
- (UIViewController *) loadResponseInforView: (ResponseViewType) type;
- (void) setupView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self->viewModel = [[ContactViewModel alloc] initWithBus: [[ContactBus alloc] initWithAdapter:[[ContactAdapter alloc] init]]];
    
    [self->viewModel requestPermission:^(BOOL granted, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self->contentViewController = [self loadContactViewController];
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
    self.view.backgroundColor = UIColor.whiteColor;
    return [ContactViewController instantiateWith:self->viewModel];
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
