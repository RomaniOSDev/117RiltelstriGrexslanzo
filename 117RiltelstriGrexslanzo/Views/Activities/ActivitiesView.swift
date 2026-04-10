//
//  ActivitiesView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct ActivitiesView: View {
    @EnvironmentObject private var storage: AppStorageStore
    @State private var selectedActivity: ActivityKind = .wharfSnap
    @State private var selectedDifficulty: GameDifficulty = .easy

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Workshop Deck")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .appPanel(cornerRadius: 18, elevated: false)
                    .padding(.top, 8)

                activitySelector
                difficultySelector
                levelGrid
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackdrop()
        .navigationTitle("Challenge Deck")
    }

    private var activitySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ActivityKind.allCases) { kind in
                    Button {
                        selectedActivity = kind
                    } label: {
                        Label(kind.title, systemImage: kind.icon)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(.horizontal, 14)
                            .frame(height: 44)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .modifier(ActivityChipBackground(isSelected: selectedActivity == kind))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var difficultySelector: some View {
        HStack(spacing: 10) {
            ForEach(GameDifficulty.allCases) { difficulty in
                Button {
                    selectedDifficulty = difficulty
                } label: {
                    Text(difficulty.title)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .modifier(DifficultyChipBackground(isSelected: selectedDifficulty == difficulty))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var levelGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1...12, id: \.self) { level in
                if storage.isLevelUnlocked(kind: selectedActivity, difficulty: selectedDifficulty, level: level) {
                    NavigationLink(value: ActivityContext(kind: selectedActivity, difficulty: selectedDifficulty, level: level)) {
                        levelCell(level: level, locked: false)
                    }
                    .buttonStyle(.plain)
                } else {
                    levelCell(level: level, locked: true)
                }
            }
        }
        .navigationDestination(for: ActivityContext.self) { context in
            ActivityPlayHost(context: context)
        }
    }

    private func levelCell(level: Int, locked: Bool) -> some View {
        VStack(spacing: 6) {
            Text("Tier \(level)")
                .font(.subheadline.bold())
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if locked {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { star in
                        Image(systemName: star < storage.stars(for: selectedActivity, difficulty: selectedDifficulty, level: level) ? "star.fill" : "star")
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 88)
        .opacity(locked ? 0.78 : 1)
        .appPanel(cornerRadius: 14, elevated: !locked)
    }
}

private struct ActivityChipBackground: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        Group {
            if isSelected {
                content.appSelectedChip(cornerRadius: 12)
            } else {
                content.appSoftFill(cornerRadius: 12)
            }
        }
    }
}

private struct DifficultyChipBackground: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        Group {
            if isSelected {
                content.appSelectedChip(cornerRadius: 12)
            } else {
                content.appSoftFill(cornerRadius: 12)
            }
        }
    }
}
