import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(.title.bold())
                    .foregroundStyle(Color.appTextPrimary)

                VStack(spacing: 12) {
                    Button(action: rateApp) {
                        SettingsRow(title: "Rate Us", icon: "star.circle.fill")
                    }
                    .buttonStyle(.plain)

                    Button(action: openPrivacyPolicy) {
                        SettingsRow(title: "Privacy Policy", icon: "lock.shield.fill")
                    }
                    .buttonStyle(.plain)

                    Button(action: openTerms) {
                        SettingsRow(title: "Terms of Use", icon: "doc.text.fill")
                    }
                    .buttonStyle(.plain)
                }
                .appCardStyle()
            }
            .padding(16)
        }
        .appScreenBackground()
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: AppLinks.privacyPolicy.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = URL(string: AppLinks.termsOfUse.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

private struct SettingsRow: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.appAccent)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(Color.appTextPrimary)
                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(12)
        .background(Color.appSurface.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
