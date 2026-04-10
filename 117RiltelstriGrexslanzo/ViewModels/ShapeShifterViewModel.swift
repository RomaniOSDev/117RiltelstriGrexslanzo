//
//  ShapeShifterViewModel.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import Foundation
import CoreGraphics
import Combine

final class WharfSnapSession: ObservableObject {
    @Published var targets: [CGPoint] = []
    @Published var pieces: [WharfTile] = []
    @Published var timeRemaining: Int = 0
    @Published var isFinished = false

    private var totalSeconds: Int = 0
    private var timer: Timer?
    private let difficulty: GameDifficulty

    init(difficulty: GameDifficulty, level: Int) {
        self.difficulty = difficulty
        totalSeconds = difficulty == .easy ? 45 : (difficulty == .normal ? 35 : 25)
        totalSeconds = max(15, totalSeconds - level)
        timeRemaining = totalSeconds
        setupPieces(level: level)
        startTimer()
    }

    deinit { timer?.invalidate() }

    func setupTargets(_ points: [CGPoint]) {
        targets = points
    }

    func updatePiece(_ piece: WharfTile) {
        if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
            pieces[index] = piece
        }
        evaluateCompletion()
    }

    func forceFinish() {
        isFinished = true
        timer?.invalidate()
    }

    func result() -> ActivityResultData {
        let placed = pieces.filter(\.isPlaced).count
        let accuracy = Int((Double(placed) / Double(max(1, pieces.count))) * 100.0)
        let used = max(1, totalSeconds - timeRemaining)
        let stars: Int
        if accuracy >= 90 && timeRemaining > totalSeconds / 3 {
            stars = 3
        } else if accuracy >= 65 {
            stars = 2
        } else if accuracy >= 35 {
            stars = 1
        } else {
            stars = 0
        }
        return ActivityResultData(stars: stars, accuracy: accuracy, completionTime: used, unlockedAchievement: nil)
    }

    private func setupPieces(level: Int) {
        let count: Int
        switch difficulty {
        case .easy: count = min(4, 2 + level / 2)
        case .normal: count = min(5, 3 + level / 2)
        case .hard: count = min(6, 4 + level / 2)
        }
        pieces = (0..<count).map { index in
            WharfTile(
                id: UUID(),
                shape: WharfGlyphKind.allCases[index % WharfGlyphKind.allCases.count],
                offset: .zero,
                angle: 0,
                targetAngle: difficulty == .hard ? Double(index * 35 % 180) : 0,
                isPlaced: false
            )
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard self.timeRemaining > 0 else {
                self.forceFinish()
                return
            }
            self.timeRemaining -= 1
        }
    }

    private func evaluateCompletion() {
        if pieces.allSatisfy(\.isPlaced) {
            forceFinish()
        }
    }
}

struct WharfTile: Identifiable {
    let id: UUID
    let shape: WharfGlyphKind
    var offset: CGSize
    var angle: Double
    let targetAngle: Double
    var isPlaced: Bool
}

enum WharfGlyphKind: CaseIterable {
    case circle, square, triangle
}
