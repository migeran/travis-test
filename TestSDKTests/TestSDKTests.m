//
//  TestSDKTests.m
//  TestSDKTests
//
//  Created by kovacsi on 31/03/16.
//  Copyright © 2016 Mattakis Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TestSDK/TestSDK.h>

@interface TestSDKTests : XCTestCase

@end

@implementation TestSDKTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // XCTAssertFalse(YES);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)test1 {
    [Test test];
}

@end
