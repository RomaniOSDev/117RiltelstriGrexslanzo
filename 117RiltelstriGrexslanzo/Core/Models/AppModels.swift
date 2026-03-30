//
//  AppModels.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import Foundation
import SwiftUI

enum ActivityKind: String, CaseIterable, Identifiable, Codable {
    case shapeShifter
    case patternMatrix
    case colorQuest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shapeShifter: return "Shape Shifter"
        case .patternMatrix: return "Pattern Matrix"
        case .colorQuest: return "Color Quest"
        }
    }

    var icon: String {
        switch self {
        case .shapeShifter: return "square.on.circle"
        case .patternMatrix: return "square.grid.3x3.fill"
        case .colorQuest: return "paintpalette.fill"
        }
    }
}

enum GameDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case normal
    case hard

    var id: String { rawValue }

    var title: String { rawValue.capitalized }
}

struct ActivityContext: Hashable {
    let kind: ActivityKind
    let difficulty: GameDifficulty
    let level: Int
}

struct ActivityResultData {
    let stars: Int
    let accuracy: Int
    let completionTime: Int
    let unlockedAchievement: String?
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let detail: String
    let isUnlocked: Bool
}
