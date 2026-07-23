//
//  LegacyBiteUITests.m
//  LegacyBiteUITests
//
//  Created by Grizly on 11.07.26.
//

#import <XCTest/XCTest.h>

@interface LegacyBiteUITests : XCTestCase

@end

@implementation LegacyBiteUITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testLaunchPerformance {

    [self measureWithMetrics:@[[[XCTApplicationLaunchMetric alloc] init]] block:^{
        [[[XCUIApplication alloc] init] launch];
    }];
}

@end
