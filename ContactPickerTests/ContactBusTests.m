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
    
    [self.contactBus loadContacts: ^(NSError * error, BOOL isDone) {
        if (isDone) {
            XCTAssertNil(error, @"Return error when load contacts");
            [loadContactExpectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
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
    NSMutableArray * loadExpectations = [[NSMutableArray alloc] init];
    
    [self.contactBus loadContacts:^(NSError * error, BOOL isDone) {
        if (isDone) {
            XCTAssertNil(error, @"Error is not nil");
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                XCTestExpectation *expectation = [self expectationWithDescription:@"load contacts"];
                [loadExpectations addObject:expectation];
                [expectation fulfill];
            });
            
            [self.contactBus getAllContacts:NO completion:^(NSArray<ContactBusEntity *> * listContacts, NSError * error) {
                XCTAssertNotNil(listContacts, @"listContacts return nil");
                XCTAssertNil(error, @"Error is not nil");
                
                ContactBusEntity * exampleContact = listContacts.firstObject;
                XCTAssertNotNil(exampleContact, @"listContacts is empty");
                dispatch_sync(dispatch_get_main_queue(), ^{
                    XCTestExpectation *expectation = [self expectationWithDescription:@"load contacts"];
                    [loadExpectations addObject:expectation];
                    [expectation fulfill];
                });
                
                [self.contactBus loadContactById:exampleContact.identifier completion:^(ContactBusEntity * contact, NSError * error) {
                    XCTAssertNotNil(contact, @"Contact from valid id is nil");
                    XCTAssertNil(error, @"Load contact from valid id have error");
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        XCTestExpectation *expectation = [self expectationWithDescription:@"load contacts"];
                        [loadExpectations addObject:expectation];
                        [expectation fulfill];
                    });
                }];
            }];
        }
    }];
    
    [self waitForExpectations:loadExpectations timeout:10];
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
    NSMutableArray * loadExpectations = [[NSMutableArray alloc] init];
    
    [self.contactBus loadContacts:^(NSError * error, BOOL isDone) {
        if(isDone) {
            XCTAssertNil(error, @"Load contact have error");
            [self.contactBus loadBatchOfDetailedContacts:^(NSArray<ContactBusEntity *> * contacts, NSError * error) {
                XCTAssertNotNil(contacts, @"Contacts is loaded but cant load batch");
                XCTAssertNil(error, @"Contacts is loaded but load batch have error");
                dispatch_sync(dispatch_get_main_queue(), ^{
                    XCTestExpectation *expectation = [self expectationWithDescription:@"load contacts"];
                    [loadExpectations addObject:expectation];
                    [expectation fulfill];
                });
            }];
        }
    }];
    
    [self waitForExpectations:loadExpectations timeout:10];
}

- (void) testGetAllContacts {
    [self.contactBus loadContacts:^(NSError * error, BOOL isDone) {
        if(isDone) {
            XCTAssertNil(error, @"Load contact have error");
            [self.contactBus getAllContacts: NO completion:^(NSArray<ContactBusEntity *> * listContacts, NSError * error) {
                XCTAssertNotNil(listContacts);
                XCTAssertNil(error, @"Get all contact have error");
            }];
        }
    }];
}

@end
