//
//  ScannerViewModelTests.swift
//  LegacyBiteTests
//
//  Created by Grizly on 24.07.26.
//

import XCTest

@testable import LegacyBite

private final class ProductLoaderMock: ProductLoading {
    var loadProductCallCount = 0
    var receivedBarCode:String?
    var productToReturn: SSProductObject?
    var errorToReturn: NSError?
    var shouldCallCompletion = true
    
    func loadProduct(barCode: String, completion: @escaping (Result<SSProductObject, NSError>) -> Void) {
        
        loadProductCallCount += 1
        receivedBarCode = barCode
        
        guard shouldCallCompletion else { return }
        
        if let productToReturn{
            completion(.success(productToReturn))
        }
        
        if let errorToReturn{
            completion(.failure(errorToReturn))
        }
    }
    
    
}

final class ScannerViewModelTests: XCTestCase {
    
    func testLoadProductWithEmptyBarCodeReturnError(){
        let producLoader = ProductLoaderMock()
        let viewModel = ScannerViewModel(productLoader: producLoader)
        
        var receivedError: NSError?
        viewModel.onError = { error in
            receivedError = error
        }
        
        viewModel.loadProduct(barCode: "")
        
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(producLoader.loadProductCallCount, 0)
        XCTAssertEqual(receivedError?.localizedDescription, "Barcode is empty")
    }
    
    func testLoadProductReturnsProductWhenLoaderSucceeds(){
        let productLoader = ProductLoaderMock()
        let expectedProduct = SSProductObject()
        
        productLoader.productToReturn = expectedProduct
        
        let viewModel = ScannerViewModel(productLoader: productLoader)
        
        var receivedProduct: SSProductObject?
        var loadingStateValues: [Bool] = []
        viewModel.onProductLoaded = { product in
            receivedProduct = product
        }
        viewModel.onLoadingChanged = { isLoading in
            loadingStateValues.append(isLoading)
        }
        
        viewModel.loadProduct(barCode: "12345")
        
        XCTAssertEqual(productLoader.loadProductCallCount, 1)
        
        XCTAssertEqual(productLoader.receivedBarCode, "12345")
        XCTAssertNotNil(receivedProduct)
        XCTAssertTrue(receivedProduct === expectedProduct)
        XCTAssertEqual(loadingStateValues, [true, false])
        
    }
    
    func testGetErrorWhenProductLoaderFails(){
        let productLoader = ProductLoaderMock()
        let expectedError = NSError(domain: "test", code: 0, userInfo:[NSLocalizedDescriptionKey: "Test error"])
        
        productLoader.errorToReturn = expectedError
        
        let viewModel = ScannerViewModel(productLoader: productLoader)
        
        var receivedError:NSError?
        var receivedProduct:SSProductObject?
        var loadingStateValues: [Bool] = []
        
        viewModel.onLoadingChanged = { isLoading in
            loadingStateValues.append(isLoading)
        }
        viewModel.onError = { error in
            receivedError = error
        }
        viewModel.onProductLoaded = {product in
            receivedProduct = product
        }
        
        viewModel.loadProduct(barCode: "12345")
        
        XCTAssertEqual(productLoader.loadProductCallCount, 1)
        XCTAssertEqual(loadingStateValues, [true, false])
        
        XCTAssertNil(receivedProduct)
        XCTAssertNotNil(receivedError)
        
        XCTAssertTrue(receivedError === expectedError)
        XCTAssertEqual(productLoader.receivedBarCode, "12345")
        
    }
    
    func testSecondRequestIsIgnoredWhileFirstRequestIsLoading() {
        let productLoader = ProductLoaderMock()
        productLoader.shouldCallCompletion = false

        let viewModel = ScannerViewModel(
            productLoader: productLoader
        )

        var loadingStateValues: [Bool] = []

        viewModel.onLoadingChanged = { isLoading in
            loadingStateValues.append(isLoading)
        }

        viewModel.loadProduct(barCode: "11111")
        viewModel.loadProduct(barCode: "22222")

        XCTAssertEqual(productLoader.loadProductCallCount, 1)
        XCTAssertEqual(productLoader.receivedBarCode, "11111")
        XCTAssertEqual(loadingStateValues, [true])
    }
}
