//
//  AppStorage.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import Foundation
import Combine

extension Notification.Name {
    static let appProgressReset = Notification.Name("appProgressReset")
}

final class AppStorageStore: ObservableObject {
    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }
    @Published private(set) var starsByLevel: [String: Int]
    @Published private(set) var unlockedLevels: [String: Int]
    @Published private(set) var totalPlayTime: TimeInterval
    @Published private(set) var totalActivitiesPlayed: Int

    private let defaults: UserDefaults
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let starsByLevel = "starsByLevel"
        static let unlockedLevels = "unlockedLevels"
        static let totalPlayTime = "totalPlayTime"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        self.starsByLevel = defaults.dictionary(forKey: Keys.starsByLevel) as? [String: Int] ?? [:]
        self.unlockedLevels = defaults.dictionary(forKey: Keys.unlockedLevels) as? [String: Int] ?? [:]
        self.totalPlayTime = defaults.double(forKey: Keys.totalPlayTime)
        self.totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
    }

    func stars(for kind: ActivityKind, difficulty: GameDifficulty, level: Int) -> Int {
        starsByLevel[levelKey(kind: kind, difficulty: difficulty, level: level)] ?? 0
    }

    func unlockedLevel(for kind: ActivityKind, difficulty: GameDifficulty) -> Int {
        max(1, unlockedLevels[unlockKey(kind: kind, difficulty: difficulty)] ?? 1)
    }

    func isLevelUnlocked(kind: ActivityKind, difficulty: GameDifficulty, level: Int) -> Bool {
        level <= unlockedLevel(for: kind, difficulty: difficulty)
    }

    func saveResult(kind: ActivityKind, difficulty: GameDifficulty, level: Int, stars: Int, duration: Int) -> String? {
        let previousAchievements = Set(achievements.filter(\.isUnlocked).map(\.id))
        let key = levelKey(kind: kind, difficulty: difficulty, level: level)
        starsByLevel[key] = max(starsByLevel[key] ?? 0, stars)
        totalPlayTime += TimeInterval(max(0, duration))
        totalActivitiesPlayed += 1

        let unlock = unlockKey(kind: kind, difficulty: difficulty)
        if stars > 0 {
            let nextLevel = min(12, level + 1)
            unlockedLevels[unlock] = max(unlockedLevels[unlock] ?? 1, nextLevel)
        }

        persist()
        let currentAchievements = achievements.filter(\.isUnlocked)
        return currentAchievements.first(where: { !previousAchievements.contains($0.id) })?.title
    }

    func resetAll() {
        hasSeenOnboarding = false
        starsByLevel = [:]
        unlockedLevels = [:]
        totalPlayTime = 0
        totalActivitiesPlayed = 0
        persist()
        NotificationCenter.default.post(name: .appProgressReset, object: nil)
    }

    var totalStars: Int {
        starsByLevel.values.reduce(0, +)
    }

    var completedLevelCount: Int {
        starsByLevel.values.filter { $0 > 0 }.count
    }

    var achievements: [Achievement] {
        [
            Achievement(id: "first_win", title: "First Victory", detail: "Complete your first challenge.", isUnlocked: totalActivitiesPlayed >= 1),
            Achievement(id: "star_collector", title: "Star Collector", detail: "Earn 20 stars in total.", isUnlocked: totalStars >= 20),
            Achievement(id: "steady_focus", title: "Steady Focus", detail: "Play for 15 minutes total.", isUnlocked: totalPlayTime >= 900),
            Achievement(id: "academy_explorer", title: "Academy Explorer", detail: "Complete 12 levels.", isUnlocked: completedLevelCount >= 12)
        ]
    }

    func totalStars(for kind: ActivityKind) -> Int {
        GameDifficulty.allCases.reduce(0) { acc, difficulty in
            acc + (1...12).reduce(0) { inner, level in
                inner + stars(for: kind, difficulty: difficulty, level: level)
            }
        }
    }

    func nextPlayableLevel(for kind: ActivityKind, difficulty: GameDifficulty) -> Int {
        let u = unlockedLevel(for: kind, difficulty: difficulty)
        return min(12, max(1, u))
    }

    private func persist() {
        defaults.set(starsByLevel, forKey: Keys.starsByLevel)
        defaults.set(unlockedLevels, forKey: Keys.unlockedLevels)
        defaults.set(totalPlayTime, forKey: Keys.totalPlayTime)
        defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed)
    }

    private func levelKey(kind: ActivityKind, difficulty: GameDifficulty, level: Int) -> String {
        "\(kind.rawValue)_\(difficulty.rawValue)_\(level)"
    }

    private func unlockKey(kind: ActivityKind, difficulty: GameDifficulty) -> String {
        "\(kind.rawValue)_\(difficulty.rawValue)"
    }
}
