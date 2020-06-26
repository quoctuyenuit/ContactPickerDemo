//
//  ContactViewModelTests.m
//  ContactPickerTests
//
//  Created by Quốc Tuyến on 6/8/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContactViewmodel.h"
#import "ContactBus.h"
#import "ContactAdapter.h"
#import "ContactBusEntity.h"

@interface ContactViewModelTests : XCTestCase
@property (nonatomic) ContactViewModel * viewModel;
@end

@implementation ContactViewModelTests

- (void)setUp {
    ContactAdapter * adapter = [[ContactAdapter alloc] init];
    ContactBus * contactBus = [[ContactBus alloc] initWithAdapter:adapter];
    self.viewModel = [[ContactViewModel alloc] initWithBus:contactBus];
}

- (void)tearDown {
    self.viewModel = nil;
}

- (void) testRequestPermission {
    [self.viewModel requestPermission:^(BOOL granted, NSError * error) {
        if (granted) {
            XCTAssertNil(error, @"User is granted but error still not nil");
        } else {
            XCTAssertNotNil(error, @"User is not granted but module dont raise error");
        }
    }];
}

- (void)testLoadContacts {
    XCTestExpectation * loadExpectation = [self expectationWithDescription:@"load contact expectation"];
    
    [self.viewModel loadContacts:^(BOOL isSuccess, NSError * _Nonnull error, NSUInteger numberOfContacts) {
        XCTAssertTrue(isSuccess, @"Load contacts is failt");
         [loadExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
