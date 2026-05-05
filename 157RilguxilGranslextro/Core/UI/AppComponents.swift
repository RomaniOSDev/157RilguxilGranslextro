import SwiftUI

struct AppPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [
                        Color.appPrimary.opacity(configuration.isPressed ? 0.75 : 0.95),
                        Color.appAccent.opacity(configuration.isPressed ? 0.65 : 0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appTextPrimary.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.appPrimary.opacity(configuration.isPressed ? 0.15 : 0.4), radius: configuration.isPressed ? 3 : 10, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
    }
}

extension View {
    func appCardStyle() -> some View {
        self
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.appSurface.opacity(0.95), Color.appBackground.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.18), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.25), radius: 10, y: 6)
    }

    func appScreenBackground() -> some View {
        self.background(
            LinearGradient(
                colors: [Color.appBackground, Color.appSurface.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
