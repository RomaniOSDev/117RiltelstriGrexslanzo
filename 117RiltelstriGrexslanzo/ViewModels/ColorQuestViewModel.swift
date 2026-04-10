//
//  ColorQuestViewModel.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import Foundation
import SwiftUI
import Combine

final class ChromaForgeSession: ObservableObject {
    enum ValidationOutcome {
        case miss
        case advanced
        case completed
    }

    @Published var red: Double = 0.5
    @Published var green: Double = 0.5
    @Published var blue: Double = 0.5
    @Published var currentTargetIndex: Int = 0

    let targets: [RGBColor]
    private let startedAt = Date()
    private var hits = 0
    private let difficulty: GameDifficulty

    init(difficulty: GameDifficulty, level: Int) {
        self.difficulty = difficulty
        let total = difficulty == .easy ? 1 : (difficulty == .normal ? 2 : 3)
        var generated: [RGBColor] = []
        for index in 0..<total {
            generated.append(RGBColor.random(difficulty: difficulty, seed: level + index))
        }
        targets = generated
    }

    var mixedColor: Color {
        Color(red: red, green: green, blue: blue)
    }

    var targetColor: RGBColor {
        targets[min(currentTargetIndex, targets.count - 1)]
    }

    var progressText: String {
        "\(min(currentTargetIndex + 1, targets.count))/\(targets.count)"
    }

    var targetRGBText: String {
        "R \(Int(targetColor.r * 255))  G \(Int(targetColor.g * 255))  B \(Int(targetColor.b * 255))"
    }

    var mixRGBText: String {
        let mix = currentMixColor()
        return "R \(mix.r255)  G \(mix.g255)  B \(mix.b255)"
    }

    var closenessPercent: Int {
        let score = channelMatchScore()
        let ratio = max(0.0, min(1.0, score))
        return Int((ratio * 100).rounded())
    }

    func validateCurrent() -> ValidationOutcome {
        if isChannelMatch() {
            hits += 1
            if currentTargetIndex < targets.count - 1 {
                currentTargetIndex += 1
                red = Double.random(in: 0...1)
                green = Double.random(in: 0...1)
                blue = Double.random(in: 0...1)
                return .advanced
            }
            return .completed
        }
        return .miss
    }

    func result() -> ActivityResultData {
        let elapsed = Int(Date().timeIntervalSince(startedAt))
        let accuracy = Int((Double(hits) / Double(targets.count)) * 100.0)
        let stars: Int = accuracy >= 100 ? 3 : (accuracy >= 67 ? 2 : (accuracy >= 34 ? 1 : 0))
        return ActivityResultData(stars: stars, accuracy: accuracy, completionTime: elapsed, unlockedAchievement: nil)
    }

    private var tolerance: Double {
        switch difficulty {
        case .easy: return 32
        case .normal: return 24
        case .hard: return 16
        }
    }

    private func isChannelMatch() -> Bool {
        let mix = currentMixColor()
        let target = rgb255(of: targetColor)
        let dr = abs(mix.r255 - target.r255)
        let dg = abs(mix.g255 - target.g255)
        let db = abs(mix.b255 - target.b255)
        return dr <= Int(tolerance) && dg <= Int(tolerance) && db <= Int(tolerance)
    }

    private func channelMatchScore() -> Double {
        let mix = currentMixColor()
        let target = rgb255(of: targetColor)
        let maxDelta = Double(max(1, Int(tolerance)))
        let sr = 1.0 - min(Double(abs(mix.r255 - target.r255)) / maxDelta, 1.0)
        let sg = 1.0 - min(Double(abs(mix.g255 - target.g255)) / maxDelta, 1.0)
        let sb = 1.0 - min(Double(abs(mix.b255 - target.b255)) / maxDelta, 1.0)
        return (sr + sg + sb) / 3.0
    }

    private func currentMixColor() -> (r255: Int, g255: Int, b255: Int) {
        (
            Int((red * 255).rounded()),
            Int((green * 255).rounded()),
            Int((blue * 255).rounded())
        )
    }

    private func rgb255(of color: RGBColor) -> (r255: Int, g255: Int, b255: Int) {
        (
            Int((color.r * 255).rounded()),
            Int((color.g * 255).rounded()),
            Int((color.b * 255).rounded())
        )
    }
}

struct RGBColor {
    let r: Double
    let g: Double
    let b: Double

    var swiftUIColor: Color { Color(red: r, green: g, blue: b) }

    func distance(to other: RGBColor) -> Double {
        let dr = r - other.r
        let dg = g - other.g
        let db = b - other.b
        return sqrt(dr * dr + dg * dg + db * db)
    }

    static func random(difficulty: GameDifficulty, seed: Int) -> RGBColor {
        let step: Double
        switch difficulty {
        case .easy: step = 0.5
        case .normal: step = 0.25
        case .hard: step = 0.1
        }
        func quantized(_ value: Double) -> Double {
            (value / step).rounded() * step
        }
        let base = Double((seed * 37) % 100) / 100.0
        let r = quantized((base + 0.21).truncatingRemainder(dividingBy: 1))
        let g = quantized((base + 0.49).truncatingRemainder(dividingBy: 1))
        let b = quantized((base + 0.77).truncatingRemainder(dividingBy: 1))
        return RGBColor(r: r, g: g, b: b)
    }
}
