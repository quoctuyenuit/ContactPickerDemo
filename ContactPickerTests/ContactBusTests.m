////
////  ContactBusTests.m
////  ContactPickerTests
////
////  Created by Quốc Tuyến on 6/8/20.
////  Copyright © 2020 LAP11963. All rights reserved.
////
//
//#import <XCTest/XCTest.h>
//#import "ContactBusinessLayer.h"
//#import "ContactAdapter.h"
//#import "ContactBusEntity.h"
//#import "Utilities.h"
//
//@interface ContactBusTests : XCTestCase
//@property (nonatomic) ContactBusinessLayer * contactBus;
//@end
//
//@implementation ContactBusTests
//
//- (void)setUp {
//    ContactAdapter * adapter = [[ContactAdapter alloc] init];
//    self.contactBus = [[ContactBusinessLayer alloc] initWithAdapter:adapter];
//}
//
//- (void)tearDown {
//    self.contactBus = nil;
//    [super tearDown];
//}
//
//- (void) testRequestPermission {
//    XCTestExpectation * permissionExpectation = [self expectationWithDescription:@"request permission expectation"];
//    [self.contactBus requestPermission:^(BOOL granted, NSError * error) {
//        if (granted) {
//            XCTAssertNil(error, @"Have error when user granted permission");
//        } else {
//            XCTAssertNotNil(error, @"Have no error when user did not granted");
//        }
//        [permissionExpectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:1 handler:nil];
//}
//
//- (void) testLoadContacts {
//    XCTestExpectation *loadContactExpectation = [self expectationWithDescription:@"load contacts"];
//    
//    [self.contactBus loadContacts:^(NSError *error, BOOL isDone, NSUInteger numberOfContacts) {
//        if (isDone) {
//            XCTAssertNil(error, @"Return error when load contacts");
//            [loadContactExpectation fulfill];
//        }
//    }];
//    
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//- (void) testLoadContactByIdWithInvalidInput {
//    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"load contact by id with empty"];
//    XCTestExpectation * wrongDataExpectation = [self expectationWithDescription:@"load contact by id with wrong data"];
//    
//    [self.contactBus loadContactById:@"" isReload: YES  completion:^(ContactBusEntity * contact, NSError * error) {
//        XCTAssertNotNil(error, @"No error when load empty identifier");
//        [emptyExpectation fulfill];
//    }];
//    
//    [self.contactBus loadContactById:@"wrongdata" isReload: YES completion:^(ContactBusEntity * contact, NSError * error) {
//        XCTAssertNotNil(error, @"No error when load wrong identifier");
//        [wrongDataExpectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:1 handler:nil];
//}
//
//- (void) testLoadBatchOfContactWithInvalidInput {
//    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"load contact by batch with empty"];
//    XCTestExpectation * wrongDataExpectation = [self expectationWithDescription:@"load contact by batch with wrong data"];
//    
//    [self.contactBus loadBatchOfDetailedContacts:@[] isReload: YES completion:^(NSArray * contacts, NSError * error) {
//        XCTAssertTrue(contacts.count == 0, @"Load non-empty contacts from empty identifiers");
//        XCTAssertNil(error, @"Load batch contact with empty identifiers have error");
//        [emptyExpectation fulfill];
//    }];
//    
//    [self.contactBus loadBatchOfDetailedContacts:@[@"123"] isReload: YES completion:^(NSArray * contacts, NSError * error) {
//        XCTAssertTrue(contacts.count == 0, @"Load contact by batch had load wrong infor");
//        XCTAssertNil(error, @"Load contact by batch have error");
//        [wrongDataExpectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:1 handler:nil];
//}
//@end
