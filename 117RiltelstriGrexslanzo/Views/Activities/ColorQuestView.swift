//
//  ColorQuestView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct ColorQuestView: View {
    let context: ActivityContext
    let onFinish: (ActivityResultData) -> Void

    @StateObject private var viewModel: ColorQuestViewModel
    @State private var statusMessage = "Adjust sliders and tap Check Color."
    @State private var attemptCount = 0

    init(context: ActivityContext, onFinish: @escaping (ActivityResultData) -> Void) {
        self.context = context
        self.onFinish = onFinish
        _viewModel = StateObject(wrappedValue: ColorQuestViewModel(difficulty: context.difficulty, level: context.level))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Target \(viewModel.progressText)")
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text(context.difficulty.title)
                        .foregroundStyle(Color.appAccent)
                }
                .font(.headline)
                .padding()
                .appPanel(cornerRadius: 14, elevated: true)

                VStack(spacing: 10) {
                    Text("Target")
                        .foregroundStyle(Color.appTextSecondary)
                    Text(viewModel.targetRGBText)
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(Color.appTextPrimary)
                    RoundedRectangle(cornerRadius: 14)
                        .fill(viewModel.targetColor.swiftUIColor)
                        .frame(height: 90)
                    Text("Your Mix")
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

                colorSlider(title: "Red", value: $viewModel.red)
                colorSlider(title: "Green", value: $viewModel.green)
                colorSlider(title: "Blue", value: $viewModel.blue)

                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: Double(viewModel.closenessPercent), total: 100)
                        .tint(Color.appAccent)
                    Text("Match accuracy: \(viewModel.closenessPercent)%")
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

                Button("Check Color") {
                    attemptCount += 1
                    switch viewModel.validateCurrent() {
                    case .miss:
                        statusMessage = "Try \(attemptCount): not close enough yet."
                    case .advanced:
                        statusMessage = "Try \(attemptCount): great match, next target."
                    case .completed:
                        statusMessage = "Try \(attemptCount): perfect, level complete."
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
        .navigationTitle("Color Quest")
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
