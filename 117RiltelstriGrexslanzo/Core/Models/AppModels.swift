//
//  AppModels.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import Foundation
import SwiftUI

enum ActivityKind: String, CaseIterable, Identifiable, Codable {
    case wharfSnap
    case glyphGrid
    case chromaForge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wharfSnap: return "Wharf Snap"
        case .glyphGrid: return "Glyph Grid"
        case .chromaForge: return "Chroma Forge"
        }
    }

    var icon: String {
        switch self {
        case .wharfSnap: return "square.stack.3d.forward.dottedline.fill"
        case .glyphGrid: return "circle.hexagongrid.fill"
        case .chromaForge: return "drop.triangle.fill"
        }
    }
}

enum GameDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case normal
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Calm"
        case .normal: return "Steady"
        case .hard: return "Peak"
        }
    }
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
