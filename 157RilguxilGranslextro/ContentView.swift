//
//  ContentView.swift
//  157RilguxilGranslextro
//
//  Created by Roman on 5/5/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = LearningDataStore()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainTabContainerView()
                    .environmentObject(dataStore)
            } else {
                OnboardingFlowView(onFinish: {
                    hasSeenOnboarding = true
                })
                .environmentObject(dataStore)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            dataStore.syncDailyStateIfNeeded()
        }
    }
}

#Preview {
    ContentView()
}
