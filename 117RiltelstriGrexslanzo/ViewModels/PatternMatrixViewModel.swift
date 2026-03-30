//
//  PatternMatrixViewModel.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import Foundation
import Combine

final class PatternMatrixViewModel: ObservableObject {
    enum Phase {
        case preview
        case solve
        case done
    }

    @Published var highlighted: Set<Int> = []
    @Published var selected: Set<Int> = []
    @Published var phase: Phase = .preview
    @Published var previewLeft: Int = 0

    let gridSize: Int
    private var timer: Timer?
    private let totalTargets: Int
    private let startedAt = Date()

    init(difficulty: GameDifficulty, level: Int) {
        gridSize = difficulty == .easy ? 3 : (difficulty == .normal ? 4 : 5)
        totalTargets = min(gridSize * gridSize - 2, 3 + level)
        previewLeft = max(2, (difficulty == .easy ? 5 : (difficulty == .normal ? 4 : 3)) - level / 4)
        generatePattern()
        startPreviewTimer()
    }

    deinit { timer?.invalidate() }

    func toggle(index: Int) {
        guard phase == .solve else { return }
        if selected.contains(index) { selected.remove(index) } else { selected.insert(index) }
    }

    func finishNow() {
        phase = .done
        timer?.invalidate()
    }

    func result() -> ActivityResultData {
        let intersection = selected.intersection(highlighted).count
        let misses = max(0, highlighted.count - intersection)
        let extras = max(0, selected.count - intersection)
        let scoreBase = max(0, intersection * 100 - misses * 30 - extras * 25)
        let maxScore = max(1, highlighted.count * 100)
        let accuracy = min(100, Int((Double(scoreBase) / Double(maxScore)) * 100.0))
        let elapsed = Int(Date().timeIntervalSince(startedAt))
        let stars: Int = accuracy >= 90 ? 3 : (accuracy >= 65 ? 2 : (accuracy >= 40 ? 1 : 0))
        return ActivityResultData(stars: stars, accuracy: accuracy, completionTime: elapsed, unlockedAchievement: nil)
    }

    private func generatePattern() {
        var pool = Array(0..<(gridSize * gridSize))
        highlighted.removeAll()
        while highlighted.count < totalTargets, let random = pool.randomElement() {
            highlighted.insert(random)
            pool.removeAll { $0 == random }
        }
    }

    private func startPreviewTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.previewLeft > 0 {
                self.previewLeft -= 1
            } else {
                self.phase = .solve
                self.timer?.invalidate()
            }
        }
    }
}
