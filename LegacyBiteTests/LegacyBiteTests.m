//
//  LegacyBiteTests.m
//  LegacyBiteTests
//
//  Created by Grizly on 11.07.26.
//

#import <XCTest/XCTest.h>
#import "SSNetworkManager.h"
#import "SSProductObject.h"

@interface SSNetworkManager (Testing)

- (SSProductObject *)serializeProduct:(NSDictionary *)dictionary;

@end

@interface LegacyBiteTests : XCTestCase

@property (strong, nonatomic) SSNetworkManager * networkManager;

@end

@implementation LegacyBiteTests

- (void)setUp {
    [super setUp];
    self.networkManager = [SSNetworkManager shared];
}

- (void)tearDown {
    self.networkManager = nil;
    [super tearDown];
}


- (void)testSerializeProductBasicFields{
    
    NSDictionary * jsonDict = @{
        @"code":@"123456789",
        @"product_name":@"Test product name",
        @"brands":@"test_brand",
        @"nutrition_grades":@"d"
    };
    
    SSProductObject * product = [self.networkManager serializeProduct:jsonDict];
    
    XCTAssertNotNil(product);
    
    XCTAssertEqualObjects(product.code, @"123456789");
    XCTAssertEqualObjects(product.name, @"Test product name");
    XCTAssertEqualObjects(product.brand, @"test_brand");
    XCTAssertEqualObjects(product.nutriScore, [@"d" uppercaseString]);
}

- (void)testSerializeProductNutriments{
    
    NSDictionary * jsonDict = @{
        @"code":@"123456789",
        @"nutriments":@{
            @"energy-kcal_100g": @534.0,
            @"fat_100g": @31.2,
            @"carbohydrates_100g": @54.05,
            @"proteins_100g": @6.1
        }
    };
    
    SSProductObject * product = [self.networkManager serializeProduct:jsonDict];
    
    XCTAssertNotNil(product);

    XCTAssertEqualWithAccuracy(product.energyKcal.doubleValue, 534.0, 0.001);
    XCTAssertEqualWithAccuracy(product.fat.doubleValue, 31.2, 0.001);
    XCTAssertEqualWithAccuracy(product.carbohydrates.doubleValue, 54.05, 0.001);
    XCTAssertEqualWithAccuracy(product.proteins.doubleValue, 6.1, 0.001);
}

- (void)testSerializeProductHandlesMissingOptionalFields {
    
    NSDictionary *json = @{
        @"code": @"123456789"
    };

    SSProductObject *product = [self.networkManager serializeProduct:json];

    XCTAssertNotNil(product);
    XCTAssertEqualObjects(product.code, @"123456789");

    XCTAssertNil(product.name);
    XCTAssertNil(product.brand);
    XCTAssertNil(product.imageURL);
    XCTAssertNil(product.nutriScore);
}

@end
