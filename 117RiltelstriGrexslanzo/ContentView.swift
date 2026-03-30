//
//  ContentView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appStorage = AppStorageStore()
    @State private var refreshID = UUID()

    var body: some View {
        Group {
            if appStorage.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    appStorage.hasSeenOnboarding = true
                }
            }
        }
        .environmentObject(appStorage)
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: .appProgressReset)) { _ in
            refreshID = UUID()
        }
    }
}

#Preview {
    ContentView()
}
