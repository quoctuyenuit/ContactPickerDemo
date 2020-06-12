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
#import "NSArrayExtension.h"

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
    
    [self.contactBus loadContacts: ^(NSArray * listContacts ,NSError * error, BOOL isDone) {
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
    
    [self.contactBus loadContactById:@"" isReload: YES  completion:^(ContactBusEntity * contact, NSError * error) {
        XCTAssertNotNil(error, @"No error when load empty identifier");
        [emptyExpectation fulfill];
    }];
    
    [self.contactBus loadContactById:@"wrongdata" isReload: YES completion:^(ContactBusEntity * contact, NSError * error) {
        XCTAssertNotNil(error, @"No error when load wrong identifier");
        [wrongDataExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadContactByIdWithValidInput {
    NSMutableArray * loadExpectations = [[NSMutableArray alloc] init];
    
    [self.contactBus loadContacts:^(NSArray * listContacts, NSError * error, BOOL isDone) {
        if (isDone) {
            XCTAssertNil(error, @"Error is not nil");
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                XCTestExpectation *expectation = [self expectationWithDescription:@"load contacts"];
                [loadExpectations addObject:expectation];
                [expectation fulfill];
            });
            
            
            XCTAssertNotNil(listContacts, @"listContacts return nil");
            XCTAssertNil(error, @"Error is not nil");
            
            ContactBusEntity * exampleContact = listContacts.firstObject;
            XCTAssertNotNil(exampleContact, @"listContacts is empty");
            dispatch_sync(dispatch_get_main_queue(), ^{
                XCTestExpectation *expectation = [self expectationWithDescription:@"load contacts"];
                [loadExpectations addObject:expectation];
                [expectation fulfill];
            });
            
            [self.contactBus loadContactById:exampleContact.identifier isReload: YES completion:^(ContactBusEntity * contact, NSError * error) {
                XCTAssertNotNil(contact, @"Contact from valid id is nil");
                XCTAssertNil(error, @"Load contact from valid id have error");
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

- (void) testLoadBatchOfContactWithInvalidInput {
    XCTestExpectation * emptyExpectation = [self expectationWithDescription:@"load contact by batch with empty"];
    XCTestExpectation * wrongDataExpectation = [self expectationWithDescription:@"load contact by batch with wrong data"];
    
    [self.contactBus loadBatchOfDetailedContacts:@[] isReload: YES completion:^(NSArray * contacts, NSError * error) {
        XCTAssertTrue(contacts.count == 0, @"Load non-empty contacts from empty identifiers");
        XCTAssertNil(error, @"Load batch contact with empty identifiers have error");
        [emptyExpectation fulfill];
    }];
    
    [self.contactBus loadBatchOfDetailedContacts:@[@"123"] isReload: YES completion:^(NSArray * contacts, NSError * error) {
        XCTAssertTrue(contacts.count == 0, @"Load contact by batch had load wrong infor");
        XCTAssertNil(error, @"Load contact by batch have error");
        [wrongDataExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void) testLoadBatchOfContactWithValidInput {
    XCTestExpectation * loadContactsExpectation = [self expectationWithDescription:@"load contact expectation"];
    XCTestExpectation * validIdentifierExpectation = [self expectationWithDescription:@"load contact by id with valid data"];
    
    [self.contactBus loadContacts: ^(NSArray<ContactDAL *> * listContacts, NSError * error, BOOL isDone) {
        if (isDone) {
            XCTAssertNotNil(listContacts, @"listContacts return nil");
            XCTAssertNil(error, @"Error is not nil");
            XCTAssertTrue(listContacts.count >= 3, @"list contact < 3");
            
            NSArray * identifiers = [[listContacts subarrayWithRange:NSMakeRange(0, 3)] map:^NSString* _Nonnull(ContactBusEntity *  _Nonnull obj) {
                return obj.identifier;
            }];
            
            XCTAssertTrue(identifiers.count == 3, @"Map in NSArray extension is wrong");
            
            [loadContactsExpectation fulfill];
            [self.contactBus loadBatchOfDetailedContacts:identifiers isReload: YES completion:^(NSArray * batchOfContact, NSError * error) {
                XCTAssertNotNil(batchOfContact, @"Contacts from list valid id is nil");
                XCTAssertTrue(batchOfContact.count == 3, @"Load missing contacts in batch");
                XCTAssertNil(error, @"Load contact from valid id have error");
                [validIdentifierExpectation fulfill];
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
