import SwiftUI

struct MainTabContainerView: View {
    @State private var selectedTab: AppTab = .learn

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                LearnHomeView()
                    .tag(AppTab.learn)
                PracticeHubView()
                    .tag(AppTab.practice)
                ProgressDashboardView()
                    .tag(AppTab.progress)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 12) {
                ForEach(AppTab.allCases) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab.rawValue)
                            .font(.headline)
                            .foregroundStyle(selectedTab == tab ? Color.appTextPrimary : Color.appTextSecondary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: selectedTab == tab
                                        ? [Color.appPrimary.opacity(0.95), Color.appAccent.opacity(0.8)]
                                        : [Color.appSurface.opacity(0.9), Color.appBackground.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.appAccent.opacity(selectedTab == tab ? 0.25 : 0.1), lineWidth: 1)
                            )
                            .shadow(color: selectedTab == tab ? Color.appPrimary.opacity(0.35) : Color.black.opacity(0.15), radius: selectedTab == tab ? 8 : 4, y: selectedTab == tab ? 4 : 2)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.appBackground, Color.appSurface.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .appScreenBackground()
    }
}
