//
//  ContactBusTests.m
//  ContactPickerTests
//
//  Created by Quốc Tuyến on 6/8/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContactBus.h"
#import "ContactAdapter.h"
#import "ContactBusEntity.h"

@interface ContactBusTests : XCTestCase
@property (nonatomic) ContactBus * contactBus;
@end

@implementation ContactBusTests

- (void)setUp {
    ContactAdapter * adapter = [[ContactAdapter alloc] init];
    self.contactBus = [[ContactBus alloc] initWithAdapter:adapter];
}

- (void)tearDown {
    self.contactBus = nil;
    [super tearDown];
}

- (void) testRequestPermission {
    XCTestExpectation * permissionExpectation = [self expectationWithDescription:@"request permission expectation"];
    [self.contactBus requestPermission:^(BOOL granted, NSError * error) {
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
    XCTestExpectation *loadContactExpectation = [self expectationWithDescription:@"load contacts"];
    
    [self.contactBus loadContacts: ^(NSError * error) {
        XCTAssertNil(error, @"Return error when load contacts");
        [loadContactExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadContactByIdWithInvalidInput {
    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"load contact by id with empty"];
    XCTestExpectation * wrongDataExpectation = [self expectationWithDescription:@"load contact by id with wrong data"];
    
    [self.contactBus loadContactById:@"" completion:^(ContactBusEntity * contact, NSError * error) {
        XCTAssertNotNil(error, @"No error when load empty identifier");
        [emptyExpectation fulfill];
    }];
    
    [self.contactBus loadContactById:@"wrongdata" completion:^(ContactBusEntity * contact, NSError * error) {
        XCTAssertNotNil(error, @"No error when load wrong identifier");
        [wrongDataExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadContactByIdWithValidInput {
    XCTestExpectation * loadContactsExpectation = [self expectationWithDescription:@"load contact expectation"];
    XCTestExpectation * validIdentifierExpectation = [self expectationWithDescription:@"load contact by id with valid data"];
    XCTestExpectation * getBaseInforExpectation = [self expectationWithDescription:@"get base information expectation"];
    
    [self.contactBus loadContacts:^(NSError * error) {
        XCTAssertNil(error, @"Error is not nil");
        [loadContactsExpectation fulfill];
        [self.contactBus getAllContacts:NO completion:^(NSArray<ContactBusEntity *> * listContacts, NSError * error) {
            XCTAssertNotNil(listContacts, @"listContacts return nil");
            XCTAssertNil(error, @"Error is not nil");
            
            ContactBusEntity * exampleContact = listContacts.firstObject;
            XCTAssertNotNil(exampleContact, @"listContacts is empty");
            [getBaseInforExpectation fulfill];
            
            [self.contactBus loadContactById:exampleContact.identifier completion:^(ContactBusEntity * contact, NSError * error) {
                XCTAssertNotNil(contact, @"Contact from valid id is nil");
                XCTAssertNil(error, @"Load contact from valid id have error");
                [validIdentifierExpectation fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadBatchOfContactWithInvalidInput {
    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"load contact by batch with empty"];
    
    [self.contactBus loadBatchOfDetailedContacts:^(NSArray<ContactBusEntity *> * contacts, NSError * error) {
        XCTAssertNil(contacts, @"Contact haven't load but can load batch");
        XCTAssertNotNil(error, @"Contact haven't load but not raise error");
        [emptyExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadBatchOfContactWithValidInput {
    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"load contact by batch with empty"];
    
    [self.contactBus loadContacts:^(NSError * error) {
        XCTAssertNil(error, @"Load contact have error");
        [self.contactBus loadBatchOfDetailedContacts:^(NSArray<ContactBusEntity *> * contacts, NSError * error) {
            XCTAssertNotNil(contacts, @"Contacts is loaded but cant load batch");
            XCTAssertNil(error, @"Contacts is loaded but load batch have error");
            [emptyExpectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testSearchContactByName {
    XCTestExpectation * searchExpectation = [self expectationWithDescription:@"load contact by batch with empty"];
    [self.contactBus loadContacts:^(NSError * error) {
        
        XCTAssertNil(error, @"Load contact have error");
        
        [self.contactBus searchContactByName:@"" completion:^(NSArray<ContactBusEntity *> * listContacts, NSError * error) {
            XCTAssertNil(error, @"search contact have error");
            XCTAssertNotNil(listContacts, @"Search contact return nil list");
            [searchExpectation fulfill];
        }];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testGetAllContacts {
    [self.contactBus loadContacts:^(NSError * error) {
        XCTAssertNil(error, @"Load contact have error");
        [self.contactBus getAllContacts: NO completion:^(NSArray<ContactBusEntity *> * listContacts, NSError * error) {
            XCTAssertNotNil(listContacts);
            XCTAssertNil(error, @"Get all contact have error");
        }];
    }];
}

@end
