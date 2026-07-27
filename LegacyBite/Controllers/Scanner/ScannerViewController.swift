//
//  ScannerViewController.swift
//  LegacyBite
//
//  Created by Grizly on 24.07.26.
//

import UIKit
import AVFoundation
import Combine

class ScannerViewController: UIViewController {

    var hasCameraAccess: Bool{
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    let viewModel = ScannerViewModel()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel(){
        viewModel.$state.receive(on: DispatchQueue.main).sink{ [weak self] state in
            self?.render(state)
        }.store(in: &cancellables)
    }
    private func render(_ state: ScannerViewModel.DataState) {
        switch state {
        case .idle:
            hideLoader()
            
        case .loading:
            showLoader()
            
        case .failed(let message):
            hideLoader()
            showAlert(message: message)
  
        case .loaded(let product):
            hideLoader()
            showProduct(product)
        }
    }
    
    @IBAction func scanBarCode(_ sender: Any) {
        Task {@MainActor in
            let authorized = await hasCameraAccess
            if authorized {
                presentCameraViewController()
            } else {
                showAccessDeniedAlert()
            }
        }
    }
    
    private func presentCameraViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard
            let navigationController = storyboard.instantiateViewController( withIdentifier: "CameraNavController" ) as? UINavigationController, let cameraViewController = navigationController.viewControllers.first as? CameraViewController
        else {
            assertionFailure("CameraNavController is configured incorrectly")
            return
        }

        cameraViewController.delegate = self
        navigationController.modalPresentationStyle = .fullScreen

        present(navigationController, animated: false)
    }
    
    private func showAccessDeniedAlert() {
        let alert = UIAlertController(
            title: nil, message: "Enable camera access in Settings to scan product barcodes.", preferredStyle: .alert
        )

        let settingsAction = UIAlertAction( title: "Settings", style: .default
        ) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            UIApplication.shared.open(url)
        }

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        )

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

        alert.addAction(
            UIAlertAction( title: "OK", style: .default )
        )

        present(alert, animated: true)
    }
    
    private func showProduct(_ product: SSProductObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "ProductCardViewController"
        ) as? ProductCardViewController else {
            assertionFailure("ProductCardViewController not found")
            return
        }

        viewController.product = product
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension ScannerViewController : @MainActor CameraViewControllerDelegate{
    func didScanBarCode(_ barCode: String) {
        Task {
            await viewModel.loadProduct(barCode: barCode)
        }
    }
    
    
}
