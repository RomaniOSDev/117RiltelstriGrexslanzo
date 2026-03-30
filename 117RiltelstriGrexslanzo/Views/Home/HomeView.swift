//
//  HomeView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var storage: AppStorageStore
    @Environment(\.mainTabSelection) private var tabSelection

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroHeader
                statRow
                nextGoalCard
                sectionTitle("Jump in")
                quickActivityScroll
                sectionTitle("Achievements")
                achievementsPreview
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .appScreenBackdrop()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(SwiftUI.Color.appTextPrimary)
    }

    private var heroHeader: some View {
        ZStack(alignment: .topLeading) {
            HomeHeroArtwork()
                .frame(height: 120)
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
                .opacity(0.95)

            VStack(alignment: .leading, spacing: 10) {
                Text("Welcome back")
                    .font(.largeTitle.bold())
                    .foregroundStyle(SwiftUI.Color.appTextPrimary)
                Text(subtitleLine)
                    .font(.subheadline)
                    .foregroundStyle(SwiftUI.Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: openActivities) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Browse activities")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .font(.headline)
                    .foregroundStyle(SwiftUI.Color.appTextPrimary)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .appProminentFill(cornerRadius: 14)
            }
            .padding(20)
            .padding(.top, 88)
        }
        .appPanel(cornerRadius: 22, elevated: true)
        .padding(.top, 8)
    }

    private var subtitleLine: String {
        if storage.totalActivitiesPlayed == 0 {
            return "Pick a challenge and collect your first stars."
        }
        if storage.totalStars > 0 {
            return "You have \(storage.totalStars) stars — keep the streak going."
        }
        return "Nice progress — open Activities to continue."
    }

    private var statRow: some View {
        HStack(spacing: 12) {
            HomeStatPill(
                icon: "star.fill",
                title: "Stars",
                value: "\(storage.totalStars)"
            )
            HomeStatPill(
                icon: "checkmark.circle.fill",
                title: "Levels",
                value: "\(storage.completedLevelCount)"
            )
            HomeStatPill(
                icon: "clock.fill",
                title: "Time",
                value: formattedPlayTime
            )
        }
    }

    private var formattedPlayTime: String {
        let sec = Int(storage.totalPlayTime)
        if sec < 60 { return "\(sec)s" }
        let m = sec / 60
        if m < 60 { return "\(m)m" }
        let h = m / 60
        let r = m % 60
        return "\(h)h \(r)m"
    }

    private var nextGoalCard: some View {
        let goal = nextTrackedGoal
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(SwiftUI.Color.appAccent)
                Text("Next goal")
                    .font(.headline)
                    .foregroundStyle(SwiftUI.Color.appTextPrimary)
                Spacer()
                Text("\(Int((goal.progress * 100).rounded()))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(SwiftUI.Color.appAccent)
            }
            Text(goal.title)
                .font(.subheadline)
                .foregroundStyle(SwiftUI.Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(SwiftUI.Color.appBackground.opacity(0.5))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    SwiftUI.Color.appAccent,
                                    SwiftUI.Color.appPrimary.opacity(0.88)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * goal.progress))
                }
            }
            .frame(height: 10)
            .clipShape(Capsule())
        }
        .padding(16)
        .appPanel(cornerRadius: 18, elevated: true)
    }

    private var nextTrackedGoal: (title: String, progress: Double) {
        if storage.totalActivitiesPlayed < 1 {
            return ("First Victory — complete any challenge once.", min(1, Double(storage.totalActivitiesPlayed)))
        }
        if storage.totalStars < 20 {
            return ("Star Collector — earn 20 stars.", min(1, Double(storage.totalStars) / 20))
        }
        if storage.totalPlayTime < 900 {
            return ("Steady Focus — play for 15 minutes total.", min(1, storage.totalPlayTime / 900))
        }
        if storage.completedLevelCount < 12 {
            return ("Academy Explorer — complete 12 levels.", min(1, Double(storage.completedLevelCount) / 12))
        }
        return ("All set! Try challenges on harder difficulty.", 1)
    }

    private var quickActivityScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(ActivityKind.allCases) { kind in
                    HomeActivityCard(
                        kind: kind,
                        totalStars: storage.totalStars(for: kind),
                        nextLevel: storage.nextPlayableLevel(for: kind, difficulty: .easy),
                        starsOnNext: storage.stars(for: kind, difficulty: .easy, level: storage.nextPlayableLevel(for: kind, difficulty: .easy))
                    )
                    .onTapGesture { openActivities() }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var achievementsPreview: some View {
        VStack(spacing: 10) {
            ForEach(storage.achievements.prefix(3)) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.isUnlocked ? "sparkles" : "lock.fill")
                        .font(.title3)
                        .foregroundStyle(item.isUnlocked ? SwiftUI.Color.appAccent : SwiftUI.Color.appTextSecondary)
                        .frame(width: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(SwiftUI.Color.appTextPrimary)
                        Text(item.detail)
                            .font(.caption)
                            .foregroundStyle(SwiftUI.Color.appTextSecondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
                .opacity(item.isUnlocked ? 1 : 0.92)
                .appPanel(cornerRadius: 14, elevated: item.isUnlocked)
            }
        }
    }

    private func openActivities() {
        withAnimation(.easeInOut(duration: 0.3)) {
            tabSelection?.wrappedValue = 1
        }
    }
}

private struct HomeStatPill: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(SwiftUI.Color.appPrimary)
            Text(value)
                .font(.headline)
                .foregroundStyle(SwiftUI.Color.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundStyle(SwiftUI.Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .appPanel(cornerRadius: 16, elevated: false)
    }
}

private struct HomeActivityCard: View {
    let kind: ActivityKind
    let totalStars: Int
    let nextLevel: Int
    let starsOnNext: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: kind.icon)
                    .font(.title2)
                    .foregroundStyle(SwiftUI.Color.appPrimary)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < starsOnNext ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundStyle(SwiftUI.Color.appAccent)
                    }
                }
            }
            Text(kind.title)
                .font(.subheadline.bold())
                .foregroundStyle(SwiftUI.Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            Text("Easy · level \(nextLevel)")
                .font(.caption)
                .foregroundStyle(SwiftUI.Color.appTextSecondary)
            Text("\(totalStars) stars total")
                .font(.caption2)
                .foregroundStyle(SwiftUI.Color.appTextSecondary.opacity(0.9))
            Spacer(minLength: 0)
            Text("Tap to open")
                .font(.caption.bold())
                .foregroundStyle(SwiftUI.Color.appAccent)
        }
        .padding(14)
        .frame(minWidth: 168, maxWidth: 168, minHeight: 160, alignment: .topLeading)
        .appPanel(cornerRadius: 18, elevated: true)
    }
}

private struct HomeHeroArtwork: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(SwiftUI.Color.appAccent.opacity(0.35 - Double(i) * 0.1), lineWidth: 2)
                    .frame(width: 40 + CGFloat(i) * 36, height: 40 + CGFloat(i) * 36)
                    .scaleEffect(pulse ? 1.05 + CGFloat(i) * 0.02 : 1)
            }
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 44))
                .foregroundStyle(SwiftUI.Color.appPrimary)
                .shadow(color: SwiftUI.Color.appAccent.opacity(0.5), radius: 8)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
