//
//  ProductDTOTests.swift
//  LegacyBiteTests
//
//  Created by Grizly on 27.07.26.
//

import Foundation
import XCTest
@testable import LegacyBite

final class ProductDTOTests: XCTestCase {
    
    func testDecodeProductBasicFields() throws {
        let json = """
                {
                  "product": {
                    "code": "1234567890",
                    "product_name": "Test product name",
                    "brands": "test_brand",
                    "nutrition_grades": "d"
                  }
                }
                """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let result = try JSONDecoder().decode(ProductResponseDTO.self, from: data)
        let product = try XCTUnwrap(result.product)
        
        XCTAssertEqual(product.code, "1234567890")
        XCTAssertEqual(product.productName, "Test product name")
        XCTAssertEqual(product.brands, "test_brand")
        XCTAssertEqual(product.nutritionGrades, "d")
    }
    
    func testDecideProductNutriments() throws {
        let json = """
                {
                  "product": {
                    "code": "123456789",
                    "nutriments": {
                      "energy-kcal_100g": 534.0,
                      "fat_100g": 31.2,
                      "carbohydrates_100g": 54.05,
                      "proteins_100g": 6.1
                    }
                  }
                }
                """
        
        let data = try XCTUnwrap(json.data(using: .utf8))
        let result = try JSONDecoder().decode(ProductResponseDTO.self, from: data)
        let nutriments = try XCTUnwrap(result.product?.nutriments)
        
        XCTAssertEqual(nutriments.energyKcal!, 534.0, accuracy: 0.001)
        XCTAssertEqual(nutriments.fat!, 31.2, accuracy: 0.001)
        XCTAssertEqual(nutriments.carbohydrates!, 54.05, accuracy: 0.001)
        XCTAssertEqual(nutriments.proteins!, 6.1, accuracy: 0.001)
    }
    
    func testDecodeProductWithMissingOptionalFields() throws {
        let json = """
                {
                  "product": {
                    "code": "123456789"
                  }
                }
                """
        
        let data = try XCTUnwrap(json.data(using: .utf8))
        let result = try JSONDecoder().decode(ProductResponseDTO.self, from: data)
        let product = try XCTUnwrap(result.product)
        
        XCTAssertEqual(product.code, "123456789")
        XCTAssertNil(product.productName)
        XCTAssertNil(product.brands)
        XCTAssertNil(product.imageFrontURL)
        XCTAssertNil(product.nutritionGrades)
        XCTAssertNil(product.nutriments)
    }
}
