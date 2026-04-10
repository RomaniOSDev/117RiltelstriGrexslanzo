//
//  PatternMatrixView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct GlyphGridPlayView: View {
    let context: ActivityContext
    let onFinish: (ActivityResultData) -> Void

    @StateObject private var viewModel: GlyphGridSession

    init(context: ActivityContext, onFinish: @escaping (ActivityResultData) -> Void) {
        self.context = context
        self.onFinish = onFinish
        _viewModel = StateObject(wrappedValue: GlyphGridSession(difficulty: context.difficulty, level: context.level))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(viewModel.phase == .preview ? "Study the glow: \(viewModel.previewLeft)s" : "Restore the same glow tiles")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .appPanel(cornerRadius: 14, elevated: false)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: viewModel.gridSize), spacing: 10) {
                    ForEach(0..<(viewModel.gridSize * viewModel.gridSize), id: \.self) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(cellGradient(index: index))
                            .frame(height: 54)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.appTextPrimary.opacity(0.2)))
                            .shadow(color: Color.appPrimary.opacity(0.12), radius: 4, x: 0, y: 2)
                            .onTapGesture { viewModel.toggle(index: index) }
                    }
                }
                .padding()
                .appPlayfield(cornerRadius: 16)

                Button("Lock Pattern") {
                    viewModel.finishNow()
                    onFinish(viewModel.result())
                }
                .buttonStyle(.plain)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, minHeight: 52)
                .appProminentFill(cornerRadius: 14)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackdrop()
        .navigationTitle(ActivityKind.glyphGrid.title)
    }

    private func cellGradient(index: Int) -> LinearGradient {
        if viewModel.phase == .preview && viewModel.highlighted.contains(index) {
            return LinearGradient(
                colors: [Color.appAccent, Color.appPrimary.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        if viewModel.phase == .solve && viewModel.selected.contains(index) {
            return LinearGradient(
                colors: [Color.appPrimary, Color.appAccent.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color.appBackground.opacity(0.55), Color.appSurface.opacity(0.35)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
