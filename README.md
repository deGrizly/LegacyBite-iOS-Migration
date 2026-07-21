# LegacyBite — iOS Legacy Migration Case Study

LegacyBite is a portfolio iOS project built as a staged modernization case study.

The app allows users to scan a product barcode, load product information from the Open Food Facts API, view nutrition details, and keep a local scan history.

The main goal of this project is not only the product scanner itself, but the migration path: from a legacy Objective-C/UIKit MVC codebase to a more modern Swift/UIKit and SwiftUI architecture.

This project intentionally starts with a classic Objective-C/UIKit baseline to demonstrate how a real legacy iOS app can be gradually improved without a full rewrite.

## Current Stage

### `v0-objc-mvc-legacy`

Objective-C / UIKit / MVC baseline.

Implemented:

- UIKit tab-based navigation: Scan, History, About
- AVFoundation barcode scanner
- Product lookup by barcode
- CoreData product cache
- Local scan history
- Cached product images
- Product detail screen
- About section with project and API information
- App logo and native iOS UI

## Migration Roadmap

- `v0-objc-mvc-legacy` — Objective-C/UIKit MVC baseline
- `v1-swift-viewmodel-bridge` — introduce Swift models/ViewModels inside UIKit
- `v2-modern-networking-swift-uikit` — modernize networking and data flow
- `v3-hybrid-uikit-swiftui` — embed SwiftUI screens into UIKit
- `v4-production-polish` — final cleanup, tests, UX improvements, and documentation

## Tech Stack

Current baseline:

- Objective-C
- UIKit
- AVFoundation
- CoreData
- Open Food Facts API

Planned modernization:

- Swift
- MVVM
- Swift Concurrency / modern networking
- SwiftUI
- XCTest

## Data Source

Product data is provided by the public Open Food Facts API.

The app does not own or verify the data returned by Open Food Facts. Product information may be incomplete, outdated, unavailable for some barcodes, or changed by the service over time.

This project uses the API for educational and portfolio purposes only.
