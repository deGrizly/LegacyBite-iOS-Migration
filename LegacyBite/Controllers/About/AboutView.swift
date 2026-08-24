//
//  AboutView.swift
//  LegacyBite
//

import SwiftUI

struct AboutView: View {
    var onSelectDetail: (AboutDetailType) -> Void

    private let rowNames = ["About Project", "Open Food Facts API", "GitHub"]

    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return "Version: \(version)"
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("app_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)
                .padding(.top, 40)

            Text("Product Scanner")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 20)

            Text("iOS Legacy Migration Case Study")
                .font(.system(size: 15))
                .padding(.top, 12)

            Text(versionText)
                .font(.system(size: 15))
                .padding(.top, 8)

            aboutPanel
                .padding(.top, 44)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }

    private var aboutPanel: some View {
        VStack(spacing: 0) {
            ForEach(Array(rowNames.enumerated()), id: \.offset) { index, name in
                if index > 0 {
                    Divider()
                        .padding(.leading, 12)
                }
                Button {
                    select(rowAt: index)
                } label: {
                    HStack {
                        Text(name)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 30)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(AboutRowButtonStyle())
            }
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    private func select(rowAt index: Int) {
        switch index {
        case 0: onSelectDetail(.project)
        case 1: onSelectDetail(.api)
        default: break // GitHub row: intentionally a no-op, matching legacy behavior
        }
    }
}

private struct AboutRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.systemGray4) : Color.clear)
    }
}
