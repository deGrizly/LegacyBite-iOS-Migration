//
//  ProductMapper.swift
//  LegacyBite
//
//  Created by Grizly on 26.07.26.
//

import Foundation

struct ProductMapper {

    func makeProduct(from dto: ProductDTO) -> SSProductObject {
        let product = SSProductObject()

        product.code = dto.code
        product.name = dto.productName
        product.brand = dto.brands
        product.quantity = dto.quantity
        product.imageURL = dto.imageFrontURL
        product.nutriScore = dto.nutritionGrades?.uppercased()

        if let energyKcal = dto.nutriments?.energyKcal {
            product.energyKcal = NSNumber(value: energyKcal)
        }

        if let proteins = dto.nutriments?.proteins {
            product.proteins = NSNumber(value: proteins)
        }

        if let fat = dto.nutriments?.fat {
            product.fat = NSNumber(value: fat)
        }

        if let carbohydrates = dto.nutriments?.carbohydrates {
            product.carbohydrates = NSNumber(value: carbohydrates)
        }

        return product
    }
}
