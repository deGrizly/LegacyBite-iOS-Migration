//
//  AboutCoordinator.swift
//  LegacyBite
//

import UIKit
import SwiftUI

@objc @MainActor final class AboutCoordinator: NSObject {
    @objc static func makeRootViewController() -> UIViewController {
        var hostingController: UIHostingController<AboutView>!

        let rootView = AboutView { type in
            let detailController = UIHostingController(rootView: AboutDetailsView(type: type))
            hostingController.navigationController?.pushViewController(detailController, animated: true)
        }

        hostingController = UIHostingController(rootView: rootView)
        hostingController.title = "About"
        hostingController.navigationItem.largeTitleDisplayMode = .always

        return hostingController
    }
}
