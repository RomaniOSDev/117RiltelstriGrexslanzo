//
//  MainTabView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Studio", systemImage: "sparkles") }
            .tag(0)

            NavigationStack {
                ActivitiesView()
            }
            .tabItem { Label("Deck", systemImage: "rectangle.stack.fill") }
            .tag(1)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Milestones", systemImage: "chart.line.uptrend.xyaxis") }
            .tag(2)
        }
        .environment(\.mainTabSelection, $selectedTab)
        .tint(Color.appPrimary)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.appSurface)
            appearance.shadowColor = UIColor(Color.appPrimary.opacity(0.2))
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
