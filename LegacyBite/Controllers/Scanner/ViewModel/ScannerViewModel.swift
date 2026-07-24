//
//  ScannerViewModel.swift
//  LegacyBite
//
//  Created by Grizly on 23.07.26.
//

import Foundation

@objcMembers
final class ScannerViewModel: NSObject {
    
    var onProductLoaded: ((SSProductObject) -> Void)?
    var onError: ((NSError) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    
    private let productLoader: ProductLoading
    private var isLoading = false
    
    override convenience init() {
        self.init(productLoader: LegacyProductLoader())
    }
    
    init(productLoader:ProductLoading){
        self.productLoader = productLoader
        super.init()
    }
    
    
    func loadProduct(barCode:String){
        guard !barCode.isEmpty else {
            onError?(makeError("Barcode is empty"))
            return
        }
        guard !isLoading else { return }
        
        isLoading = true
        onLoadingChanged?(true)
        
        productLoader.loadProduct(barCode: barCode){[weak self] result in
            guard let self else { return }
            self.isLoading = false
            self.onLoadingChanged?(false)
            switch result {
            case .success(let product):
                self.onProductLoaded?(product)
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    private func makeError(_ message: String) -> NSError {
        NSError(domain: Bundle.main.bundleIdentifier ?? "LegacyBite", code: -1, userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}
