# LegacyBite — iOS Legacy Migration Case Study

LegacyBite is a portfolio iOS project that demonstrates the staged modernization of a working Objective-C/UIKit application.

The app scans product barcodes, loads nutrition data from the Open Food Facts API, displays product details, and keeps a local scan history.

The goal is not to hide the legacy code behind a full rewrite. Each stage introduces a focused architectural improvement while keeping the application buildable and preserving existing behaviour. Significant stages are saved as Git tags and GitHub Releases.

## Current Stage

### `v3-swiftui-integration`

Stage 3 introduces SwiftUI into the application for the first time, using the About screen as a self-contained, low-risk vertical slice with no networking or Core Data dependencies.

The About screen now uses:

- SwiftUI views for both the root screen (`AboutView`) and the detail screen (`AboutDetailsView`)
- Fully programmatic construction — no storyboard scene, XIB, or Interface Builder identifiers
- `UIHostingController` embedding each SwiftUI view as a leaf inside the existing UIKit `UINavigationController` stack
- A small Swift coordinator (`AboutCoordinator`), exposed to Objective-C, that builds the hosting controllers and bridges row taps back into UIKit's imperative push navigation
- Closure-based navigation instead of a nested SwiftUI `NavigationStack`, so the tab's existing UIKit navigation bar and large-title behaviour stay unchanged
- XCTest coverage for the coordinator's view controller construction

The rest of the app remains unchanged: the Scanner flow stays Swift/MVVM/Combine, History and Product Detail stay Objective-C/MVC, and Core Data persistence and image caching stay behind their existing Objective-C boundaries.

## Application Features

- Tab-based UIKit navigation: Scan, History, and About
- AVFoundation barcode scanning
- Product lookup through the Open Food Facts API
- Nutrition and Nutri-Score display
- Core Data product cache
- Local scan history
- Cached product images
- Objective-C and Swift interoperability
- Storyboard-based navigation
- Unit and UI tests

## Architecture

### Product loading flow

```text
ScannerViewController (Swift UIKit)
        │
        │ barcode
        ▼
ScannerViewModel (Swift, @MainActor)
        │
        │ async ProductServiceLoading
        ▼
ProductService (Swift)
        │
        ├── Cache lookup
        │      ▼
        │   LegacyProductCache (Swift adapter)
        │      ▼
        │   CoreDataManager (Objective-C)
        │
        └── Cache miss
               ▼
            NetworkClient (Swift, URLSession)
               ▼
            ProductResponseDTO / ProductDTO (Codable)
               ▼
            ProductMapper
               ▼
            SSProductObject (Objective-C model)
               ▼
            LegacyProductCache → CoreDataManager
```

### View state flow

```text
ScannerViewModel
    @Published state
        │
        ▼
Combine subscription
        │
        ▼
ScannerViewController
    idle / loading / loaded / failed
```

### Intentionally retained legacy boundaries

```text
HistoryViewController (Objective-C)
        ▼
ProductManager (Objective-C, history facade)
        ▼
CoreDataManager (Objective-C)

ProductCardViewController (Objective-C)
        ▼
SSNetworkManager (Objective-C, image loading and NSCache)
```

### UIKit ↔ SwiftUI navigation boundary

```text
RootTabBarController (Objective-C)
        │
        │ builds the About tab
        ▼
AboutCoordinator.makeRootViewController() (Swift)
        │
        ▼
UIHostingController<AboutView>
        │   pushed as the tab's root view controller,
        │   inside the pre-existing UINavigationController
        │
        │ row tap → onSelectDetail closure
        ▼
UIHostingController<AboutDetailsView>
        │   pushed via hostingController.navigationController?
        │          .pushViewController(_:animated:)
        ▼
AboutDetailsView (SwiftUI)
```

SwiftUI views are leaves inside the pre-existing UIKit navigation stack — there is no nested SwiftUI `NavigationStack`. UIKit still owns the tab bar, the navigation bar, and the push/pop transitions; SwiftUI only owns the content of each screen.

This structure reflects a realistic production migration: modern code is introduced around stable legacy boundaries instead of replacing every component at once.

## Key Technical Decisions

### Cache-first product loading

`ProductService` checks the local cache before making a network request. A cache miss triggers the Swift networking flow, maps the decoded DTO into the existing `SSProductObject`, and stores the result through `LegacyProductCache`.

### Separate transport and application models

The Open Food Facts response is decoded into Swift `Codable` DTOs. `ProductMapper` then converts the API representation into the legacy Objective-C model used by the existing screens and Core Data layer.

This prevents API field names and response structure from leaking into UI and persistence code.

### Main-actor UI state

`ScannerViewModel` is isolated to `@MainActor`. It publishes explicit states:

```swift
enum DataState {
    case idle
    case loading
    case loaded(SSProductObject)
    case failed(String)
}
```

The ViewModel validates the barcode, prevents overlapping requests, awaits the injected product service, and updates the state consumed by the UIKit controller through Combine.

### Protocol-based dependency injection

The scanner flow depends on abstractions rather than concrete networking and persistence implementations. Tests provide mocks without performing live network requests or writing to the production Core Data store.

### SwiftUI screens as leaves in the UIKit navigation stack

The About screen is built entirely in SwiftUI, but does not introduce its own navigation container. `AboutCoordinator` constructs a `UIHostingController` for each screen and pushes it through the enclosing `UINavigationController` that `RootTabBarController` already owns, using a plain closure rather than a nested SwiftUI `NavigationStack`.

This keeps the hybrid boundary explicit and narrow: UIKit remains the single source of truth for navigation across the whole app, while SwiftUI is free to evolve independently, screen by screen, in later stages.

## Migration Roadmap

| Stage | Status | Description |
|---|---:|---|
| `v0-objc-mvc-legacy` | Complete | Final Objective-C/UIKit MVC baseline |
| `v1-swift-viewmodel-bridge` | Complete | Introduced a testable Swift ViewModel behind an Objective-C scanner controller |
| `v2-modern-swift-data-flow` | Complete | Migrated the scanner controller to Swift UIKit, introduced Combine state binding, and rebuilt the product-loading flow with `async/await`, `URLSession`, `Codable`, mapping, and a legacy persistence adapter |
| `v3-swiftui-integration` | Current | Add a meaningful SwiftUI screen to the existing UIKit application through a hybrid navigation boundary |
| `v4-cleanup-production-polish` | Planned | Remove remaining dead code, improve UX and accessibility, expand test coverage, add CI, and finalize project documentation |

Stage numbers start at zero, so Stage 2 is the third preserved step in the migration history.

## Testing

The project uses XCTest to protect behaviour while implementations are replaced.

### DTO decoding

- Basic Open Food Facts product fields
- Nutrition values
- Missing optional fields

### Product mapping

- Basic product fields
- Nutri-Score normalization
- Nutrition values
- Missing optional values

### Scanner ViewModel

- Empty barcode validation
- Successful loading
- Error state propagation
- Published state transitions
- Ignoring a second request while the first request is running

### UI testing

- Basic application launch smoke test

Tests use injected mocks and local JSON samples. They do not depend on the live Open Food Facts service.

## Tech Stack

### Current

- Objective-C
- Swift 6
- UIKit
- SwiftUI
- Combine
- Swift Concurrency
- URLSession
- Codable
- Storyboards
- AVFoundation
- Core Data
- XCTest
- MVC for retained legacy screens
- MVVM for the scanner flow
- `UIHostingController`-based UIKit/SwiftUI interoperability

### Planned

- Accessibility and UX improvements
- Continuous Integration

## Project Structure

```text
LegacyBite/
├── Controllers/
│   ├── Scanner/                 # Swift UIKit + Combine + MVVM
│   ├── History/                 # Objective-C legacy screen
│   ├── ProductInfo/             # Objective-C legacy screen
│   └── About/                   # SwiftUI, fully programmatic (UIHostingController)
├── Managers/
│   ├── NetworkManager/          # Swift product API + ObjC image loader
│   ├── ProductManager/          # Swift ProductService + ObjC history facade
│   └── ProductObject/           # Codable DTOs, mapper, ObjC product model
├── CoreData/
│   ├── LegacyProductCache.swift # Swift-to-Objective-C persistence adapter
│   └── CoreDataManager.*        # Retained Objective-C persistence boundary
└── Storyboards/

LegacyBiteTests/
├── ProductDTOTests.swift
├── ProductMapperTests.swift
├── ScannerViewModelTests.swift
└── AboutCoordinatorTests.swift
```

## Running the Project

1. Clone the repository.
2. Open `LegacyBite.xcodeproj`.
3. Select an iOS 16 or later simulator or device.
4. Build and run the `LegacyBite` scheme.
5. Grant camera access to scan a physical barcode, or use cached/history data when running in the simulator.
6. Run the test suite with **Product → Test**.

The project has no third-party package dependencies.

## Migration Principles

- Preserve working behaviour before replacing implementation details
- Avoid a risky full rewrite
- Modernize one vertical slice at a time
- Keep interoperability boundaries explicit
- Separate transport, domain flow, persistence, and UI responsibilities
- Add or update tests with every architectural change
- Keep every migration stage buildable and reviewable
- Preserve significant stages with Git tags and GitHub Releases

## Data Source

Product information is provided by the public Open Food Facts API.

The application does not own or verify the returned data. Product information may be incomplete, outdated, unavailable for some barcodes, or changed by the service.

This project uses the API for educational and portfolio purposes only.
