//
//  ScannerViewModel.swift
//  LegacyBite
//
//  Created by Grizly on 23.07.26.
//

import Foundation
import Combine


@MainActor
final class ScannerViewModel: ObservableObject {
    
    enum DataState: Equatable {
        case idle, loading, loaded(SSProductObject), failed(String)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle): return true
            case (.loading, .loading): return true
            case let (.failed(lhsMessage), .failed(rhsMessage)):
                return lhsMessage == rhsMessage
            case let (.loaded(lhsProduct), .loaded(rhsProduct)):
                return lhsProduct === rhsProduct
            default: return false
            }
        }
    }

    @Published private(set) var state: DataState = .idle
    
    private let productLoader: ProductServiceLoading
    private var isLoading = false

    init(productLoader:ProductServiceLoading = ProductService()){
        self.productLoader = productLoader
    }
    
    
    func loadProduct(barCode:String) async{
        guard !barCode.isEmpty else {
            state = .failed(ProductApiError.emptyBarCode.localizedDescription)
            return
        }
        guard !isLoading else { return }
        
        isLoading = true
        state = .loading
        
        
        defer {
            
            self.isLoading = false
        }
        do {
            let product = try await productLoader.loadProduct(barCode: barCode)
            
            state = .loaded(product)
        } catch {
            
            state = .failed(error.localizedDescription)
        }
            
        
    }

}

