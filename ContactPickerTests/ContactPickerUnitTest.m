//
//  ContactAdapterTests.m
//  ContactPickerTests
//
//  Created by Quốc Tuyến on 6/7/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContactAdapter.h"
#import "ContactBus.h"
#import "ContactDAL.h"
#import <Contacts/Contacts.h>


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
}

- (void) testLoadContactsFromAdapter {
    
    XCTestExpectation *loadContactAdapterExpectation = [self expectationWithDescription:@"load contacts"];
    
    [self.contactAdapter loadContacts:^(NSArray<ContactDAL *> * listContacts, NSError * error) {
        XCTAssertNil(error, @"The loadContacts is failt");
        [loadContactAdapterExpectation fulfill];
    }];
    
    [self waitForExpectations:@[loadContactAdapterExpectation] timeout:1];
}

- (void) testLoadContactById {
    XCTestExpectation *emptyExpectation = [self expectationWithDescription:@"load contact by id with empty"];
    XCTestExpectation *wrongDataExpectation = [self expectationWithDescription:@"load contact by id with wrong data"];
    
    [self.contactAdapter loadContactById:@"" completion:^(ContactDAL * contact, NSError * error) {
        XCTAssertNotNil(error, @"Load contact by identifier not cover empty case");
        [emptyExpectation fulfill];
    }];
    
    [self.contactAdapter loadContactById:@"wrongdata" completion:^(ContactDAL * contact, NSError * error) {
        XCTAssertNotNil(error, @"Load contact by identifier not cover empty case");
        [wrongDataExpectation fulfill];
    }];
    [self waitForExpectations:@[emptyExpectation, wrongDataExpectation] timeout:1];
}

- (void) testLoadContactByBatchWithEmpty {
    XCTestExpectation *emptyExpectation = [self expectationWithDescription:@"load contact by batch with empty"];
    XCTestExpectation *wrongDataExpectation = [self expectationWithDescription:@"load contact by batch with wrong data"];
    
    [self.contactAdapter loadContactByBatch:@[] completion:^(NSArray * contacts, NSError * error) {
        XCTAssertNotNil(error, @"Load contact by identifier not cover empty case");
        [emptyExpectation fulfill];
    }];
    
    [self.contactAdapter loadContactByBatch:@[@"123"] completion:^(NSArray * contacts, NSError * error) {
        XCTAssertTrue(contacts.count == 0, @"Load contact by batch had load wrong infor");
        XCTAssertNil(error, @"Load contact by batch have error");
        [wrongDataExpectation fulfill];
    }];
    
    [self waitForExpectations:@[emptyExpectation, wrongDataExpectation] timeout:1];
}


@end
