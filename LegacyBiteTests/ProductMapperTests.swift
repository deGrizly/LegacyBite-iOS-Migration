//
//  ProductMapperTests.swift
//  LegacyBiteTests
//
//  Created by Grizly on 27.07.26.
//

import Foundation
import XCTest
@testable import LegacyBite

final class ProductMapperTests: XCTestCase {
    func testMakeProductMapsBasicFields() {
        let dto = ProductDTO(
            code: "1234567890",
            productName: "Test product name",
            brands: "test_brand",
            quantity: "100 g",
            imageFrontURL: URL(string: "https://example.com/image.jpg"),
            nutritionGrades: "d",
            nutriments: nil
        )
        let mapper = ProductMapper()
        let product = mapper.makeProduct(from: dto)
        XCTAssertEqual(product.code, "1234567890")
        XCTAssertEqual(product.name, "Test product name")
        XCTAssertEqual(product.brand, "test_brand")
        XCTAssertEqual(product.quantity, "100 g")
        XCTAssertEqual(product.imageURL, URL(string: "https://example.com/image.jpg")
        )
        XCTAssertEqual(product.nutriScore, "D")
    }
    
    func testMakeProductMapsNutriments() {
        
        let nutriments = NutrimentsDTO(
            energyKcal: 534.0,
            proteins: 6.1,
            fat: 31.2,
            carbohydrates: 54.05
        )

        let dto = ProductDTO(
            code: "123456789",
            productName: nil,
            brands: nil,
            quantity: nil,
            imageFrontURL: nil,
            nutritionGrades: nil,
            nutriments: nutriments
        )
        
        let mapper = ProductMapper()
        
        let product = mapper.makeProduct(from: dto)
        
        XCTAssertEqual(product.energyKcal!.doubleValue, 534.0, accuracy: 0.001)
        XCTAssertEqual(product.proteins!.doubleValue, 6.1, accuracy: 0.001)
        XCTAssertEqual(product.fat!.doubleValue, 31.2, accuracy: 0.001)
        XCTAssertEqual(product.carbohydrates!.doubleValue, 54.05, accuracy: 0.001)
    }

    func testMakeProductWithMissingOptionalFields() {
        let dto = ProductDTO(
            code: "123456789",
            productName: nil,
            brands: nil,
            quantity: nil,
            imageFrontURL: nil,
            nutritionGrades: nil,
            nutriments: nil
        )
        
        let mapper = ProductMapper()
        let product = mapper.makeProduct(from: dto)

        XCTAssertEqual(product.code, "123456789")
        XCTAssertNil(product.name)
        XCTAssertNil(product.brand)
        XCTAssertNil(product.imageURL)
        XCTAssertNil(product.nutriScore)
    }
}
