//
//  AboutCoordinatorTests.swift
//  LegacyBiteTests
//

import XCTest
import SwiftUI

@testable import LegacyBite

@MainActor
final class AboutCoordinatorTests: XCTestCase {

    func testMakeRootViewControllerHasAboutTitleAndSwiftUIRoot() {
        let viewController = AboutCoordinator.makeRootViewController()

        XCTAssertEqual(viewController.title, "About")
        XCTAssertTrue(viewController is UIHostingController<AboutView>)
        XCTAssertEqual(viewController.navigationItem.largeTitleDisplayMode, .always)
    }
}
