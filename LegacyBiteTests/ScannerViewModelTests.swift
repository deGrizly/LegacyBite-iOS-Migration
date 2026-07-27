//
//  ScannerViewModelTests.swift
//  LegacyBiteTests
//
//  Created by Grizly on 24.07.26.
//

import XCTest
import Combine

@testable import LegacyBite

@MainActor
private final class ProductLoaderMock: ProductServiceLoading {

    var loadProductCallCount = 0
    var receivedBarCode:String?
    var productToReturn: SSProductObject?
    var errorToReturn: NSError?
    var delayNanoseconds: UInt64 = 0
    
    func loadProduct(barCode: String) async throws -> SSProductObject {
        loadProductCallCount += 1
        receivedBarCode = barCode
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        if let productToReturn {
            return productToReturn
        }
        if let errorToReturn {
            throw errorToReturn
        }
        fatalError("Mock is not configured")
    }
}

final class ScannerViewModelTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    @MainActor
    func testLoadProductWithEmptyBarCodeReturnError() async{
        let productLoader = ProductLoaderMock()
        let viewModel = ScannerViewModel(productLoader: productLoader)
        await viewModel.loadProduct(barCode: "")
        
        XCTAssertEqual(viewModel.state, ScannerViewModel.DataState.failed(ProductApiError.emptyBarCode.localizedDescription))
        XCTAssertEqual(productLoader.loadProductCallCount, 0)
    }
    
    @MainActor
    func testLoadProductReturnsProductWhenLoaderSucceeds() async{
        let productLoader = ProductLoaderMock()
        let expectedProduct = SSProductObject()
        
        productLoader.productToReturn = expectedProduct
        
        let viewModel = ScannerViewModel(productLoader: productLoader)
        
        var receivedStates: [ScannerViewModel.DataState] = []
        
        viewModel.$state
            .sink{ state in receivedStates.append(state)}
            .store(in: &cancellables)
        
        await viewModel.loadProduct(barCode: "12345")
        
        
        XCTAssertEqual(productLoader.loadProductCallCount, 1)
        XCTAssertEqual(productLoader.receivedBarCode, "12345")
        
        XCTAssertEqual(receivedStates, [.idle,.loading,.loaded(expectedProduct)])
        
        XCTAssertEqual(viewModel.state, ScannerViewModel.DataState.loaded(expectedProduct))
        
    }
    @MainActor
    func testGetErrorWhenProductLoaderFails() async {
        let productLoader = ProductLoaderMock()
        let expectedError = NSError(domain: "test", code: 0, userInfo:[NSLocalizedDescriptionKey: "Test error"])
        
        productLoader.errorToReturn = expectedError
        
        let viewModel = ScannerViewModel(productLoader: productLoader)
        
        var receivedStates: [ScannerViewModel.DataState] = []
        viewModel.$state
            .sink {state in receivedStates.append(state)}
            .store(in: &cancellables)
        
        await viewModel.loadProduct(barCode: "12345")
        
        
        XCTAssertEqual(productLoader.loadProductCallCount, 1)
        XCTAssertEqual(productLoader.receivedBarCode, "12345")
        XCTAssertEqual(receivedStates, [.idle,.loading,.failed(expectedError.localizedDescription)])
        XCTAssertEqual(viewModel.state, ScannerViewModel.DataState.failed("Test error"))
        
    }
    
    @MainActor
    func testSecondRequestIsIgnoredWhileFirstRequestIsLoading() async {
        let product = SSProductObject()

        let productLoader = ProductLoaderMock()
        productLoader.productToReturn = product
        productLoader.delayNanoseconds = 300_000_000

        let viewModel = ScannerViewModel(
            productLoader: productLoader
        )

        var receivedStates: [ScannerViewModel.DataState] = []

        viewModel.$state
            .sink { state in
                receivedStates.append(state)
            }
            .store(in: &cancellables)
        
        let firstTask = Task {
            await viewModel.loadProduct(barCode: "11111")
        }
        
        
        await Task.yield()
        
        await viewModel.loadProduct(barCode: "22222")

        await firstTask.value

        XCTAssertEqual(productLoader.loadProductCallCount, 1)
        XCTAssertEqual(productLoader.receivedBarCode, "11111")
        XCTAssertEqual(
            receivedStates,
            [.idle, .loading, .loaded(product)]
        )
    }
}
