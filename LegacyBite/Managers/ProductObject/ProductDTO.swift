//
//  ProductDTO.swift
//  LegacyBite
//
//  Created by Grizly on 26.07.26.
//

import Foundation

struct ProductResponseDTO: Decodable {
    let product: ProductDTO?
}

struct ProductDTO: Decodable {
    let code: String?
    let productName: String?
    let brands: String?
    let quantity: String?
    let imageFrontURL: URL?
    let nutritionGrades: String?
    let nutriments: NutrimentsDTO?

    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case brands
        case quantity
        case imageFrontURL = "image_front_url"
        case nutritionGrades = "nutrition_grades"
        case nutriments
    }
}

struct NutrimentsDTO: Decodable {
    let energyKcal: Double?
    let proteins: Double?
    let fat: Double?
    let carbohydrates: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal = "energy-kcal_100g"
        case proteins = "proteins_100g"
        case fat = "fat_100g"
        case carbohydrates = "carbohydrates_100g"
    }
}
