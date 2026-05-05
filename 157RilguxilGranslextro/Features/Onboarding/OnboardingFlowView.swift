import SwiftUI

struct OnboardingFlowView: View {
    @State private var page = 0
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackground, Color.appSurface.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            TabView(selection: $page) {
                OnboardingKnowledgeTreePage()
                    .tag(0)
                OnboardingBookPage()
                    .tag(1)
                OnboardingPathPage(startAction: onFinish)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 34)
            }
        }
    }
}

private struct OnboardingKnowledgeTreePage: View {
    @State private var branchGrowth = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appPrimary.opacity(0.28), Color.appSurface.opacity(0.2)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 150
                        )
                    )
                    .frame(width: 260, height: 260)
                    .overlay(
                        Circle()
                            .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.appPrimary.opacity(0.25), radius: 16)

                Path { path in
                    path.move(to: CGPoint(x: 120, y: 220))
                    path.addLine(to: CGPoint(x: 120, y: 130))
                    path.move(to: CGPoint(x: 120, y: 170))
                    path.addLine(to: CGPoint(x: 75, y: 135))
                    path.move(to: CGPoint(x: 120, y: 160))
                    path.addLine(to: CGPoint(x: 165, y: 120))
                    path.move(to: CGPoint(x: 75, y: 135))
                    path.addLine(to: CGPoint(x: 55, y: 95))
                    path.move(to: CGPoint(x: 165, y: 120))
                    path.addLine(to: CGPoint(x: 185, y: 85))
                }
                .trim(from: 0, to: branchGrowth)
                .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .frame(width: 240, height: 240)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: branchGrowth)

                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(Color.appPrimary.opacity(branchGrowth > 0.75 ? 1 : 0))
                        .frame(width: 14, height: 14)
                        .offset(x: [-50, 45, -65, 68, 0, 0][index], y: [-10, -24, -50, -62, -72, -95][index])
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.appSurface.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 8)
            )
            Spacer()
            Text("Start Your Learning Journey")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.appSurface.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 22)
        .onAppear { branchGrowth = 1.0 }
    }
}

private struct OnboardingBookPage: View {
    @State private var openBook = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appSurface, Color.appBackground.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 210, height: 150)
                    .shadow(color: Color.appPrimary.opacity(0.25), radius: 12, y: 6)

                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.appAccent)
                        .frame(width: 86, height: 130)
                        .rotationEffect(.degrees(openBook ? -22 : 0), anchor: .trailing)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.appPrimary)
                        .frame(width: 86, height: 130)
                        .rotationEffect(.degrees(openBook ? 22 : 0), anchor: .leading)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: openBook)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.appSurface.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 8)
            )

            Text("Discover concepts through short, focused lessons.")
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.appSurface.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 22)
        .onAppear { openBook = true }
    }
}

private struct OnboardingPathPage: View {
    let startAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Canvas { context, size in
                let path = Path { p in
                    p.move(to: CGPoint(x: 20, y: size.height - 20))
                    p.addCurve(to: CGPoint(x: size.width - 20, y: 20),
                               control1: CGPoint(x: size.width * 0.2, y: size.height * 0.5),
                               control2: CGPoint(x: size.width * 0.7, y: size.height * 0.8))
                }
                context.stroke(path, with: .color(.appAccent), style: StrokeStyle(lineWidth: 6, lineCap: .round))
            }
            .frame(height: 220)
            .appCardStyle()
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appPrimary.opacity(0.2), lineWidth: 1)
            )

            Button("Start Learning", action: startAction)
                .buttonStyle(AppPrimaryButtonStyle())
                .shadow(color: .appPrimary, radius: 10)
                .padding(.horizontal, 16)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 22)
    }
}
