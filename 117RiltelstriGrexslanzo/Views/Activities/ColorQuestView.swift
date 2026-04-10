//
//  ColorQuestView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct ChromaForgePlayView: View {
    let context: ActivityContext
    let onFinish: (ActivityResultData) -> Void

    @StateObject private var viewModel: ChromaForgeSession
    @State private var statusMessage = "Slide the channels, then tap Forge Check."
    @State private var attemptCount = 0

    init(context: ActivityContext, onFinish: @escaping (ActivityResultData) -> Void) {
        self.context = context
        self.onFinish = onFinish
        _viewModel = StateObject(wrappedValue: ChromaForgeSession(difficulty: context.difficulty, level: context.level))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Batch \(viewModel.progressText)")
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text(context.difficulty.title)
                        .foregroundStyle(Color.appAccent)
                }
                .font(.headline)
                .padding()
                .appPanel(cornerRadius: 14, elevated: true)

                VStack(spacing: 10) {
                    Text("Reference hue")
                        .foregroundStyle(Color.appTextSecondary)
                    Text(viewModel.targetRGBText)
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(Color.appTextPrimary)
                    RoundedRectangle(cornerRadius: 14)
                        .fill(viewModel.targetColor.swiftUIColor)
                        .frame(height: 90)
                    Text("Your forge")
                        .foregroundStyle(Color.appTextSecondary)
                    Text(viewModel.mixRGBText)
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(Color.appTextPrimary)
                    RoundedRectangle(cornerRadius: 14)
                        .fill(viewModel.mixedColor)
                        .frame(height: 90)
                }
                .padding()
                .appPanel(cornerRadius: 16, elevated: true)

                colorSlider(title: "Red channel", value: $viewModel.red)
                colorSlider(title: "Green channel", value: $viewModel.green)
                colorSlider(title: "Blue channel", value: $viewModel.blue)

                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: Double(viewModel.closenessPercent), total: 100)
                        .tint(Color.appAccent)
                    Text("Forge alignment: \(viewModel.closenessPercent)%")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(14)
                .appPanel(cornerRadius: 14, elevated: false)

                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .appSoftFill(cornerRadius: 14)

                Button("Forge Check") {
                    attemptCount += 1
                    switch viewModel.validateCurrent() {
                    case .miss:
                        statusMessage = "Attempt \(attemptCount): channels need more tuning."
                    case .advanced:
                        statusMessage = "Attempt \(attemptCount): locked — next reference ready."
                    case .completed:
                        statusMessage = "Attempt \(attemptCount): forge complete."
                        onFinish(viewModel.result())
                    }
                }
                .buttonStyle(.plain)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, minHeight: 52)
                .appProminentFill(cornerRadius: 14)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackdrop()
        .navigationTitle(ActivityKind.chromaForge.title)
    }

    private func colorSlider(title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(Int(value.wrappedValue * 255))")
                    .foregroundStyle(Color.appAccent)
            }
            Slider(value: value, in: 0...1)
                .tint(Color.appPrimary)
        }
        .padding()
        .appSoftFill(cornerRadius: 14)
    }
}
