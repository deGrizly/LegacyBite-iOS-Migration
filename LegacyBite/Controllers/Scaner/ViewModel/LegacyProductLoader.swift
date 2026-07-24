//
//  LegacyProductLoader.swift
//  LegacyBite
//
//  Created by Grizly on 23.07.26.
//

import Foundation

final class LegacyProductLoader: ProductLoading {
    
    private let productManager:ProductManager
    
    init(productManager: ProductManager = ProductManager.shared()) {
        self.productManager = productManager
    }
    
    func loadProduct(barCode: String, completion: @escaping (Result<SSProductObject, NSError>) -> Void) {
        productManager.getProductForBarCode(barCode) {result, networkError in

            if let error = networkError as? NSError {
                completion(.failure(error))
            } else if let product = result{
                completion(.success(product))
            } else {
                completion(.failure(NSError(domain: Bundle.main.bundleIdentifier ?? "LegacyBite", code: -1, userInfo: [NSLocalizedDescriptionKey:"Something went wrong. Try again latter."])))
            }
        }
    }
}
