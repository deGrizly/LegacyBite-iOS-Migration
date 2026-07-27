//
//  ProductApiError.swift
//  LegacyBite
//
//  Created by Grizly on 26.07.26.
//

import Foundation

enum ProductApiError: LocalizedError, Equatable {
    static func == (lhs: ProductApiError, rhs: ProductApiError) -> Bool {
        switch (lhs, rhs) {
        case (.emptyBarCode, .emptyBarCode),
            (.invalidURL, .invalidURL),
            (.invalidResponse, .invalidResponse),
            (.emptyData, .emptyData),
            (.productNotFound, .productNotFound),
            (.decodingFailed, .decodingFailed):
            return true
            
        case (.httpStatus(let leftCode), .httpStatus(let rightCode)):
            return leftCode == rightCode
            
        case (.unowned(let leftError), .unowned(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
            
        default:
            return false
        }
    }
    
    case emptyBarCode
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case emptyData
    case productNotFound
    case decodingFailed
    case unowned (Error)
    
    var errorDescription: String? {
        switch self {
        case .emptyBarCode:
            return "BarCode is empty"
        case .invalidURL:
            return "Could not create product URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpStatus(let code):
            return "HTTP status: \(code)"
        case .emptyData:
            return "Server returned empty data"
        case .productNotFound:
            return "Product was not found"
        case .decodingFailed:
            return "Unable to decode product data"
        case .unowned(let error):
            return error.localizedDescription
        }
    }
}
