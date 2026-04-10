//
//  ActivityPlayHost.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct ActivityPlayHost: View {
    @EnvironmentObject private var storage: AppStorageStore
    @Environment(\.dismiss) private var dismiss

    @State private var context: ActivityContext
    @State private var resultData: ActivityResultData?

    init(context: ActivityContext) {
        _context = State(initialValue: context)
    }

    var body: some View {
        ZStack {
            switch context.kind {
            case .wharfSnap:
                WharfSnapPlayView(context: context, onFinish: finish)
            case .glyphGrid:
                GlyphGridPlayView(context: context, onFinish: finish)
            case .chromaForge:
                ChromaForgePlayView(context: context, onFinish: finish)
            }
        }
        .fullScreenCover(item: $resultData) { result in
            ResultView(
                result: result,
                onNext: { goToNextLevelOrDismiss() },
                onRetry: { self.resultData = nil },
                onLevels: { self.resultData = nil; dismiss() }
            )
        }
    }

    private func finish(_ result: ActivityResultData) {
        let achievement = storage.saveResult(
            kind: context.kind,
            difficulty: context.difficulty,
            level: context.level,
            stars: result.stars,
            duration: result.completionTime
        )
        resultData = ActivityResultData(
            stars: result.stars,
            accuracy: result.accuracy,
            completionTime: result.completionTime,
            unlockedAchievement: achievement
        )
    }

    private func goToNextLevelOrDismiss() {
        resultData = nil
        let next = context.level + 1
        if next <= 12 {
            context = ActivityContext(kind: context.kind, difficulty: context.difficulty, level: next)
        } else {
            dismiss()
        }
    }
}

extension ActivityResultData: Identifiable {
    var id: String { "\(stars)-\(accuracy)-\(completionTime)-\(unlockedAchievement ?? "none")" }
}
