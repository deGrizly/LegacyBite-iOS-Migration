# LegacyBite — iOS Legacy Migration Case Study

LegacyBite is a portfolio iOS project built as a staged modernization case study.

The app allows users to scan a product barcode, load product information from the Open Food Facts API, view nutrition details, and keep a local scan history.

The main goal of the project is to demonstrate a gradual migration from a legacy Objective-C/UIKit MVC codebase to a modern Swift-based architecture without performing a full rewrite.

Each migration stage is preserved with a separate Git tag and GitHub Release.

## Current Stage

### `v1-swift-viewmodel-bridge`

The scanner flow now uses a Swift ViewModel inside the existing Objective-C/UIKit application.

The project remains intentionally hybrid:

* View controllers are still written in Objective-C
* UIKit and Storyboards remain in use
* Existing networking and Core Data services remain unchanged
* Swift is introduced behind a small interoperability boundary
* Scanner business logic is independently unit tested

### Scanner Flow

```text
ScannerViewController (Objective-C)
        ↓
ScannerViewModel (Swift)
        ↓
ProductLoading protocol
        ↓
LegacyProductLoader
        ↓
ProductManager (Objective-C)
```

`ScannerViewController` remains responsible for:

* Camera permissions
* Barcode scanner presentation
* Loading indicator
* Alerts
* Navigation to the product screen

`ScannerViewModel` is responsible for:

* Barcode validation
* Loading state
* Preventing duplicate requests
* Product loading results
* Error propagation

`LegacyProductLoader` adapts the existing Objective-C `ProductManager` to the Swift `ProductLoading` protocol.

This keeps the existing application behavior while introducing dependency injection and testable Swift logic.

## Implemented Features

* UIKit tab-based navigation: Scan, History, About
* AVFoundation barcode scanner
* Product lookup by barcode
* Core Data product cache
* Local scan history
* Cached product images
* Product detail screen
* About section with project and API information
* Objective-C and Swift interoperability
* Swift ViewModel for the scanner flow
* Dependency injection through `ProductLoading`
* Unit tests for legacy response mapping
* Unit tests for `ScannerViewModel`
* UI launch smoke test

## Migration Roadmap

* `v0-objc-mvc-legacy` — final Objective-C/UIKit MVC baseline
* `v1-swift-viewmodel-bridge` — introduce a testable Swift ViewModel inside the Objective-C scanner flow
* `v2-swift-uikit-combine` — migrate scanner and history controllers to Swift UIKit and replace bridge callbacks with Combine
* `v3-swift-domain-persistence` — introduce a Swift domain model and modernize Core Data mapping and migration
* `v4-modern-data-layer` — replace legacy networking with URLSession, Codable, async/await, and repository abstractions
* `v5-hybrid-uikit-swiftui` — embed SwiftUI screens into the existing UIKit application
* `v6-production-polish` — expand test coverage, improve accessibility and UX, add CI, and finalize documentation

## Tech Stack

### Current

* Objective-C
* Swift
* UIKit
* Storyboards
* AVFoundation
* Core Data
* Open Food Facts API
* XCTest
* MVC (legacy screens)
* MVVM (scanner flow)

### Planned

* Swift UIKit
* Combine
* URLSession
* Codable
* Swift Concurrency
* Repository pattern
* SwiftUI
* Continuous Integration

## Testing

The project uses XCTest to preserve existing behavior during the migration.

### Legacy coverage

* Mapping Open Food Facts JSON fields into the Objective-C product model
* Mapping nutrition values
* Handling responses with missing optional fields
* Basic application launch smoke test

### ScannerViewModel coverage

* Empty barcode validation
* Successful product loading
* Product loading failure
* Ignoring a second request while the first request is still running

The scanner tests use a mock implementation of `ProductLoading`, allowing the ViewModel to be tested without performing real network requests.

## Migration Approach

The migration follows several rules:

* Preserve working behavior before replacing implementation details
* Avoid rewriting the entire application at once
* Introduce Swift behind small and explicit boundaries
* Add tests before modernizing deeper layers
* Keep each stage buildable and usable
* Preserve every significant migration stage with a Git tag and GitHub Release

The History screen remains in the existing Objective-C MVC implementation during the current stage because it contains little independent presentation logic. It will be migrated when the UIKit controllers move to Swift.

## Data Source

Product data is provided by the public Open Food Facts API.

The app does not own or verify the data returned by Open Food Facts. Product information may be incomplete, outdated, unavailable for some barcodes, or changed by the service over time.

This project uses the API for educational and portfolio purposes only.
