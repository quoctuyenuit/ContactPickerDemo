//
//  ContactAdapterTests.m
//  ContactPickerTests
//
//  Created by Quốc Tuyến on 6/7/20.
//  Copyright © 2020 LAP11963. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ContactAdapter.h"
//#import "DataBinding.h"

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

- (void) testLoadContacts {
    [self.contactAdapter loadContacts:^(NSArray<ContactDAL *> * listContacts, BOOL isSuccess) {
        XCTAssertTrue(isSuccess, @"The loadContacts is failt");
    }];
}

@end
