//
//  SettingsView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Support & legal")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)

                settingsButton(title: "Rate us", systemImage: "star.circle.fill") {
                    rateApp()
                }

                settingsButton(title: "Privacy Policy", systemImage: "hand.raised.fill") {
                    if let url = URL(string: AppExternalLink.privacyPolicy.rawValue) {
                        UIApplication.shared.open(url)
                    }
                }

                settingsButton(title: "Terms of Use", systemImage: "doc.text.fill") {
                    if let url = URL(string: AppExternalLink.termsOfUse.rawValue) {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .appScreenBackdrop()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingsButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 32)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .appPanel(cornerRadius: 16, elevated: true)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
