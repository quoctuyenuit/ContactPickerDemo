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
#import "NSArrayExtension.h"

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

- (void) testLoadContacts {
    XCTestExpectation * loadContactAdapterExpectation = [self expectationWithDescription:@"load contacts"];
    
    [self.contactAdapter loadContacts:^(NSArray<ContactDAL *> * listContacts, NSError * error) {
        XCTAssertNotNil(listContacts, @"listContacts return nil");
        XCTAssertNil(error, @"Error is not nil");
        [loadContactAdapterExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadContactByIdWithInvalidInput {
    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"load contact by id with empty"];
    XCTestExpectation * wrongDataExpectation = [self expectationWithDescription:@"load contact by id with wrong data"];
    
    [self.contactAdapter loadContactById:@"" completion:^(ContactDAL * contact, NSError * error) {
        XCTAssertNotNil(error, @"No error when load empty identifier");
        [emptyExpectation fulfill];
    }];
    
    [self.contactAdapter loadContactById:@"wrongdata" completion:^(ContactDAL * contact, NSError * error) {
        XCTAssertNotNil(error, @"No error when load wrong identifier");
        [wrongDataExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadContactByIdWithValidInput {
    XCTestExpectation * loadContactsExpectation = [self expectationWithDescription:@"load contact expectation"];
    XCTestExpectation * validIdentifierExpectation = [self expectationWithDescription:@"load contact by id with valid data"];
    
    [self.contactAdapter loadContacts:^(NSArray<ContactDAL *> * listContacts, NSError * error) {
           XCTAssertNotNil(listContacts, @"listContacts return nil");
           XCTAssertNil(error, @"Error is not nil");
           
           ContactDAL * exampleContact = listContacts.firstObject;
           XCTAssertNotNil(exampleContact, @"listContacts is empty");
           
           [loadContactsExpectation fulfill];
           [self.contactAdapter loadContactById:exampleContact.contactID completion:^(ContactDAL * contact, NSError * error) {
               XCTAssertNotNil(contact, @"Contact from valid id is nil");
               XCTAssertNil(error, @"Load contact from valid id have error");
               [validIdentifierExpectation fulfill];
           }];
       }];
    
     [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadBatchOfContactWithInvalidInput {
    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"load contact by batch with empty"];
    XCTestExpectation * wrongDataExpectation = [self expectationWithDescription:@"load contact by batch with wrong data"];
    
    [self.contactAdapter loadBatchOfContacts:@[] completion:^(NSArray * contacts, NSError * error) {
        XCTAssertTrue(contacts.count == 0, @"Load non-empty contacts from empty identifiers");
        XCTAssertNil(error, @"Load batch contact with empty identifiers have error");
        [emptyExpectation fulfill];
    }];
    
    [self.contactAdapter loadBatchOfContacts:@[@"123"] completion:^(NSArray * contacts, NSError * error) {
        XCTAssertTrue(contacts.count == 0, @"Load contact by batch had load wrong infor");
        XCTAssertNil(error, @"Load contact by batch have error");
        [wrongDataExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadBatchOfContactWithValidInput {
    XCTestExpectation * loadContactsExpectation = [self expectationWithDescription:@"load contact expectation"];
    XCTestExpectation * validIdentifierExpectation = [self expectationWithDescription:@"load contact by id with valid data"];
    
    [self.contactAdapter loadContacts:^(NSArray<ContactDAL *> * listContacts, NSError * error) {
        XCTAssertNotNil(listContacts, @"listContacts return nil");
        XCTAssertNil(error, @"Error is not nil");
        XCTAssertTrue(listContacts.count >= 3, @"list contact < 3");
        
        NSArray * identifiers = [[listContacts subarrayWithRange:NSMakeRange(0, 3)] map:^NSString* _Nonnull(ContactDAL *  _Nonnull obj) {
            return obj.contactID;
        }];
        
        XCTAssertTrue(identifiers.count == 3, @"Map in NSArray extension is wrong");
        
        [loadContactsExpectation fulfill];
        [self.contactAdapter loadBatchOfContacts:identifiers completion:^(NSArray * batchOfContact, NSError * error) {
            XCTAssertNotNil(batchOfContact, @"Contacts from list valid id is nil");
            XCTAssertTrue(batchOfContact.count == 3, @"Load missing contacts in batch");
            XCTAssertNil(error, @"Load contact from valid id have error");
            [validIdentifierExpectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
