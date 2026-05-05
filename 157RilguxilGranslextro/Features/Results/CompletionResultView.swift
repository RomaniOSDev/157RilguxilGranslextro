import SwiftUI

struct CompletionResultView: View {
    let result: AppResultData
    let onNextTopic: () -> Void
    let onReview: () -> Void

    @State private var visibleStars = 0
    @State private var showBanner = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if showBanner {
                    Text("Achievement Unlocked")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.appPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .offset(y: showBanner ? 0 : -80)
                        .animation(.easeInOut(duration: 2.0), value: showBanner)
                }

                Text(result.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < visibleStars ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(Color.appAccent)
                            .scaleEffect(index < visibleStars ? 1 : 0.7)
                    }
                }
                .padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Correct: \(result.correctCount)")
                    Text("Incorrect: \(result.incorrectCount)")
                }
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()

                if let summary = result.summary {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Summary")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Accuracy: \(summary.accuracyPercent)%")
                        Text("Response Speed: \(summary.responseSpeedLabel)")
                        Text("Strongest Topic: \(summary.strongestTopic)")
                        Text(summary.nextRecommendation)
                    }
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardStyle()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Missed Explanations")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    ForEach(result.explanations, id: \.self) { explanation in
                        Text("• \(explanation)")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardStyle()

                Button("Next Topic", action: onNextTopic)
                    .buttonStyle(AppPrimaryButtonStyle())
                Button("Review", action: onReview)
                    .buttonStyle(AppPrimaryButtonStyle())
            }
            .padding(16)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            let clampedStars = max(0, min(3, result.stars))
            visibleStars = 0
            if clampedStars > 0 {
                for index in 1...clampedStars {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                        withAnimation(.spring()) { visibleStars = index }
                    }
                }
            }
            showBanner = clampedStars == 3
        }
    }
}
