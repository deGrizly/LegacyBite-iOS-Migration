//
//  NetworkCient.swift
//  LegacyBite
//
//  Created by Grizly on 27.07.26.
//

import Foundation

protocol NetworkApiClientProtocol: Sendable {
    func getProduct(barcode: String) async throws -> ProductDTO
}

final class NetworkClient: NetworkApiClientProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getProduct(barcode: String) async throws -> ProductDTO {
        guard !barcode.isEmpty else {
            throw ProductApiError.emptyBarCode
        }

        var components = URLComponents(
            string: "https://world.openfoodfacts.org/api/v3/product/\(barcode)"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "fields",
                value: "code,product_name,brands,quantity,image_front_url,nutrition_grades,nutriments"
            )
        ]

        guard let url = components?.url else {
            throw ProductApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw ProductApiError.invalidResponse
        }

        guard 200..<300 ~= response.statusCode else {
            throw ProductApiError.httpStatus(response.statusCode)
        }

        do {
            let responseDTO = try JSONDecoder().decode(
                ProductResponseDTO.self,
                from: data
            )

            guard let product = responseDTO.product else {
                throw ProductApiError.productNotFound
            }

            return product
        } catch let error as ProductApiError {
            throw error
        } catch {
            throw ProductApiError.decodingFailed
        }
    }
}
