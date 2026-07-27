//
//  LegacyProductCache.swift
//  LegacyBite
//
//  Created by Grizly on 27.07.26.
//

import Foundation
@MainActor
protocol ProductCache {
    func product(barcode: String) throws -> SSProductObject?
    func save(_ product: SSProductObject) throws
}

@MainActor
final class LegacyProductCache: ProductCache {

    func product(barcode: String) throws -> SSProductObject? {
        var error: NSError?

        let product = CoreDataManager.shared().getProductBy(barcode, error:&error)

        if let error {
            throw error
        }

        return product
    }

    func save(_ product: SSProductObject) throws {
        try CoreDataManager.shared().saveProduct(product)
    }
}
