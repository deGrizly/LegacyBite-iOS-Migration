//
//  AboutDetailsView.swift
//  LegacyBite
//

import SwiftUI

enum AboutDetailType {
    case project
    case api
}

private let aboutProjectText = "LegacyBite is a portfolio iOS project built as a staged modernization case study.\nThe app allows users to scan a product barcode, load basic product information, view nutrition details, and keep a local scan history.\nThe main goal of this project is not only the product scanner itself, but the migration path: from a legacy Objective-C/UIKit MVC codebase to a more modern Swift/UIKit and SwiftUI architecture.\nThis project intentionally starts with a classic UIKit/Objective-C baseline to demonstrate how a real legacy iOS app can be gradually improved without a full rewrite."

private let aboutApiText = "Product data in this app is provided by the public Open Food Facts API.\nOpen Food Facts is an open food products database that allows apps and services to look up product information by barcode. LegacyBite uses this API to display product names, brands, ingredients, images, and nutrition values when available.\nThe app does not own, verify, or control the data returned by Open Food Facts. Product information may be incomplete, outdated, unavailable for some barcodes, or changed by the Open Food Facts service over time.\nThis project uses the API for educational and portfolio purposes only. The displayed information should not be treated as medical, dietary, or professional advice."

struct AboutDetailsView: View {
    let type: AboutDetailType

    private var text: String {
        switch type {
        case .project: return aboutProjectText
        case .api: return aboutApiText
        }
    }

    var body: some View {
        ScrollView {
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color(.systemGray))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
        }
    }
}
