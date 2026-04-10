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
                sectionTitle("Pick a lane")
                quickActivityScroll
                sectionTitle("Badges")
                achievementsPreview
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .appScreenBackdrop()
        .navigationTitle("Studio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(SwiftUI.Color.appTextPrimary)
    }

    private var heroHeader: some View {
        ZStack(alignment: .topLeading) {
            StudioHeroMark()
                .frame(height: 120)
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
                .opacity(0.95)

            VStack(alignment: .leading, spacing: 10) {
                Text("Studio pulse")
                    .font(.largeTitle.bold())
                    .foregroundStyle(SwiftUI.Color.appTextPrimary)
                Text(subtitleLine)
                    .font(.subheadline)
                    .foregroundStyle(SwiftUI.Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: openDeck) {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.stack.fill")
                        Text("Open the deck")
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
            return "Start a workshop run and earn your first spark rating."
        }
        if storage.totalStars > 0 {
            return "You hold \(storage.totalStars) sparks — climb the next tier."
        }
        return "Solid momentum — jump back into the deck anytime."
    }

    private var statRow: some View {
        HStack(spacing: 12) {
            HomeStatPill(
                icon: "star.fill",
                title: "Sparks",
                value: "\(storage.totalStars)"
            )
            HomeStatPill(
                icon: "checkmark.circle.fill",
                title: "Tiers",
                value: "\(storage.completedLevelCount)"
            )
            HomeStatPill(
                icon: "clock.fill",
                title: "Focus",
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
                Image(systemName: "scope")
                    .foregroundStyle(SwiftUI.Color.appAccent)
                Text("Focus target")
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
            return ("First Spark — complete any workshop once.", min(1, Double(storage.totalActivitiesPlayed)))
        }
        if storage.totalStars < 20 {
            return ("Star Trail — gather 20 sparks.", min(1, Double(storage.totalStars) / 20))
        }
        if storage.totalPlayTime < 900 {
            return ("Deep Run — stay in flow for 15 minutes overall.", min(1, storage.totalPlayTime / 900))
        }
        if storage.completedLevelCount < 12 {
            return ("Atlas Seeker — clear 12 tier checkpoints.", min(1, Double(storage.completedLevelCount) / 12))
        }
        return ("Deck mastered — chase Peak mode scores.", 1)
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
                    .onTapGesture { openDeck() }
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

    private func openDeck() {
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
            Text("Calm · tier \(nextLevel)")
                .font(.caption)
                .foregroundStyle(SwiftUI.Color.appTextSecondary)
            Text("\(totalStars) sparks in this lane")
                .font(.caption2)
                .foregroundStyle(SwiftUI.Color.appTextSecondary.opacity(0.9))
            Spacer(minLength: 0)
            Text("Tap for deck")
                .font(.caption.bold())
                .foregroundStyle(SwiftUI.Color.appAccent)
        }
        .padding(14)
        .frame(minWidth: 168, maxWidth: 168, minHeight: 160, alignment: .topLeading)
        .appPanel(cornerRadius: 18, elevated: true)
    }
}

private struct StudioHeroMark: View {
    @State private var drift = false

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                RoundedRectangle(cornerRadius: 12 - CGFloat(i) * 2, style: .continuous)
                    .stroke(SwiftUI.Color.appAccent.opacity(0.28 - Double(i) * 0.06), lineWidth: 2)
                    .frame(width: 48 + CGFloat(i) * 32, height: 48 + CGFloat(i) * 20)
                    .rotationEffect(.degrees(Double(i) * 8 + (drift ? 4 : -4)))
            }
            Image(systemName: "wand.and.stars")
                .font(.system(size: 44))
                .foregroundStyle(SwiftUI.Color.appPrimary)
                .shadow(color: SwiftUI.Color.appAccent.opacity(0.45), radius: 10)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}
