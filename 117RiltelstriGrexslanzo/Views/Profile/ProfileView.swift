//
//  ProfileView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var storage: AppStorageStore
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Progress")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 8)

                NavigationLink {
                    SettingsView()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(Color.appPrimary)
                        Text("Settings")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
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

                statRow(title: "Activities Played", value: "\(storage.totalActivitiesPlayed)")
                statRow(title: "Play Time", value: "\(Int(storage.totalPlayTime)) sec")
                statRow(title: "Stars Earned", value: "\(storage.totalStars)")

                Text("Achievements")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appTextPrimary)
                ForEach(storage.achievements) { achievement in
                    HStack {
                        Image(systemName: achievement.isUnlocked ? "star.fill" : "star")
                            .foregroundStyle(achievement.isUnlocked ? Color.appAccent : Color.appTextSecondary)
                        VStack(alignment: .leading) {
                            Text(achievement.title)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Text(achievement.detail)
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .appPanel(cornerRadius: 14, elevated: achievement.isUnlocked)
                }

                Button("Reset All Progress") {
                    showResetAlert = true
                }
                .buttonStyle(.plain)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, minHeight: 52)
                .appProminentFill(cornerRadius: 14)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .alert("Reset all progress?", isPresented: $showResetAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        storage.resetAll()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackdrop()
        .navigationTitle("Profile")
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appAccent)
        }
        .padding()
        .appPanel(cornerRadius: 14, elevated: false)
    }
}
