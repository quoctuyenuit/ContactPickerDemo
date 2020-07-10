//
//  ContactAdapterTests.m
//  ContactPickerTests
//
//  Created by Quốc Tuyến on 6/7/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContactAdapter.h"
#import "ContactBusinessLayer.h"
#import "ContactDAL.h"
#import <Contacts/Contacts.h>
#import "Utilities.h"

@interface ContactAdapterTests : XCTestCase
@property (nonatomic) ContactAdapter * contactAdapter;
@end

@implementation ContactAdapterTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.contactAdapter = [[ContactAdapter alloc] init];
    [self setContinueAfterFailure:NO];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    self.contactAdapter = nil;
    [super tearDown];
}

- (void) testRequestPermission {
    XCTestExpectation * permissionExpectation = [self expectationWithDescription:@"request permission expectation"];
    [self.contactAdapter requestPermission:^(BOOL granted, NSError * error) {
        if (granted) {
            XCTAssertNil(error, @"Have error when user granted permission");
        } else {
            XCTAssertNotNil(error, @"Have no error when user did not granted");
        }
        [permissionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testLoadContacts {
    XCTestExpectation *expectation = [self expectationWithDescription:@"load contacts"];
    
    [self.contactAdapter loadContactsWithBlock:^(NSArray<id<ContactDALProtocol>> *contacts, NSError *error) {
        XCTAssertNotNil(contacts, @"listContacts return nil");
        XCTAssertNil(error, @"Error is not nil");
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:5];
}

- (void)testStressLoadContacts {
    int numberStress = 100;
    NSMutableArray * expectationList = [NSMutableArray array];
    
    for (int i = 0; i < numberStress; i++) {
        NSLog(@"[Test]current i: %d", i);
        XCTestExpectation * expect = [self expectationWithDescription:@"load contacts"];
        [expectationList addObject:expect];
        [self.contactAdapter loadContactsWithBlock:^(NSArray<id<ContactDALProtocol>> *contacts, NSError *error) {
            XCTAssertNotNil(contacts, @"listContacts return nil");
            XCTAssertNil(error, @"Error is not nil");
            [expect fulfill];
        }];
    }
    
    [self waitForExpectations:expectationList timeout:5];
}

- (void)testLoadImages {
    XCTestExpectation *expectation = [self expectationWithDescription:@"load contacts"];
    
    [self.contactAdapter loadContactImagesWithBlock:^(NSDictionary<NSString *,NSData *> *images, NSError *error) {
        XCTAssertNotNil(images, @"listContacts return nil");
        XCTAssertNil(error, @"Error is not nil");
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:5];
}

- (void)testStressLoadImages {
    int numberStress = 100;
    NSMutableArray * expectationList = [NSMutableArray array];
    
    for (int i = 0; i < numberStress; i++) {
        NSLog(@"[Test]current i: %d", i);
        XCTestExpectation * expect = [self expectationWithDescription:@"load contact images"];
        [expectationList addObject:expect];
        [self.contactAdapter loadContactImagesWithBlock:^(NSDictionary<NSString *,NSData *> *images, NSError *error) {
            XCTAssertNotNil(images, @"listContacts return nil");
            XCTAssertNil(error, @"Error is not nil");
            [expect fulfill];
        }];
    }
    
    [self waitForExpectations:expectationList timeout:5];
}

- (void)testLoadContactByIdWithInvalidInput {
    XCTestExpectation * expect = [self expectationWithDescription:@"load contact by id"];
    [self.contactAdapter loadContactById:@"abc" block:^(id<ContactDALProtocol> contact, NSError *error) {
        XCTAssertNil(contact, @"contact is not nil with invalid input");
        XCTAssertNotNil(error, @"erorr is not nil with invalid input");
        [expect fulfill];
    }];
    [self waitForExpectations:@[expect] timeout:2];
}

- (void)testGetImageByIdWithInvalidInput {
    XCTestExpectation * expect = [self expectationWithDescription:@"load contact by id"];
    [self.contactAdapter loadImageWithIdentifier:nil block:^(NSData *image, NSError *error) {
        XCTAssertNil(image, @"Return image is not nil with invalid id");
        XCTAssertNotNil(error, @"erorr is not nil with invalid input");
        [expect fulfill];
    }];
    [self waitForExpectations:@[expect] timeout:2];
}
@end
