//
//  ProductService.swift
//  LegacyBite
//
//  Created by Grizly on 27.07.26.
//

import Foundation

@MainActor
protocol ProductServiceLoading {
    func loadProduct(barCode: String) async throws -> SSProductObject
}

@MainActor
final class ProductService: ProductServiceLoading {

    private let apiClient: NetworkApiClientProtocol
    private let cache: ProductCache
    private let mapper: ProductMapper

    init(
        apiClient: NetworkApiClientProtocol = NetworkCient(),
        cache: ProductCache = LegacyProductCache(),
        mapper: ProductMapper = ProductMapper()
    ) {
        self.apiClient = apiClient
        self.cache = cache
        self.mapper = mapper
    }

    func loadProduct(barCode: String) async throws -> SSProductObject {
        if let cachedProduct = try cache.product(barcode: barCode) {
            return cachedProduct
        }

        let dto = try await apiClient.getProduct(barcode: barCode)
        let product = mapper.makeProduct(from: dto)

        try cache.save(product)

        return product
    }
}
