//
//  ContactBusTests.m
//  ContactPickerTests
//
//  Created by Quốc Tuyến on 6/8/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContactBusinessLayer.h"
#import "ContactAdapter.h"
#import "ContactBusEntity.h"
#import "Utilities.h"

@interface ContactBusTests : XCTestCase
@property (nonatomic) ContactBusinessLayer * contactBus;
@end

@implementation ContactBusTests

- (void)setUp {
    ContactAdapter * adapter = [[ContactAdapter alloc] init];
    self.contactBus = [[ContactBusinessLayer alloc] initWithAdapter:adapter];
}

- (void)tearDown {
    self.contactBus = nil;
    [super tearDown];
}

- (void) testRequestPermission {
    XCTestExpectation * permissionExpectation = [self expectationWithDescription:@"request permission expectation"];
    [self.contactBus requestPermissionWithBlock:^(BOOL granted, NSError * error) {
        if (granted) {
            XCTAssertNil(error, @"Have error when user granted permission");
        } else {
            XCTAssertNotNil(error, @"Have no error when user did not granted");
        }
        [permissionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testStressSearch {
    NSInteger numberStress = 100;
    NSMutableArray * expectationList = [NSMutableArray array];
    for (NSInteger i = 0; i < numberStress; i++) {
        [NSThread sleepForTimeInterval:0.1];
        NSString * searchText = [NSString stringWithFormat:@"%ld", i];
        
        XCTestExpectation * expect = [self expectationWithDescription:@"load contacts"];
        [expectationList addObject:expect];
        
        [self.contactBus searchContactByName:searchText block:^(NSArray<id<ContactBusEntityProtocol>> *contacts, NSError *error) {
            NSLog(@"[Test] complete: %@", searchText);
            XCTAssertNotNil(contacts, @"Search return nil result");
            XCTAssertNil(error, @"Search return error result");
            [expect fulfill];
        }];
    }
    
    [self waitForExpectations:expectationList timeout:1000];
}
@end
