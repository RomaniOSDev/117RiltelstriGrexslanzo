//
//  ResultView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct ResultView: View {
    let result: ActivityResultData
    let onNext: () -> Void
    let onRetry: () -> Void
    let onLevels: () -> Void

    @State private var visibleStars = 0
    @State private var showBanner = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                if let achievement = result.unlockedAchievement, showBanner {
                    Text("Achievement unlocked: \(achievement)")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appAccent, Color.appPrimary.opacity(0.92)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.appAccent.opacity(0.45), radius: 14, x: 0, y: 6)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Text("Great Job!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < visibleStars ? "star.fill" : "star")
                            .font(.system(size: 42))
                            .foregroundStyle(Color.appAccent)
                            .shadow(color: Color.appAccent.opacity(0.8), radius: index < visibleStars ? 12 : 0)
                    }
                }
                .padding(.vertical, 6)

                resultCard(title: "Accuracy", value: "\(result.accuracy)%")
                resultCard(title: "Completion Time", value: "\(result.completionTime) sec")
                resultCard(title: "Stars Earned", value: "\(result.stars)")

                actionButton(title: "Next Level", style: .primary, action: onNext)
                actionButton(title: "Retry", style: .accent, action: onRetry)
                actionButton(title: "Back to Levels", style: .neutral, action: onLevels)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .appScreenBackdrop()
        .onAppear {
            for i in 0..<result.stars {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        visibleStars = max(visibleStars, i + 1)
                    }
                }
            }
            if result.unlockedAchievement != nil {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                    showBanner = true
                }
            }
        }
    }

    private func resultCard(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(Color.appAccent)
        }
        .padding()
        .appPanel(cornerRadius: 14, elevated: false)
    }

    private enum ActionStyle {
        case primary, accent, neutral
    }

    private func actionButton(title: String, style: ActionStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, minHeight: 52)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .buttonStyle(.plain)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradientPair(for: style),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                if style == .neutral {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.appPrimary.opacity(0.22), lineWidth: 1)
                }
            }
            .shadow(color: Color.appPrimary.opacity(style == .neutral ? 0.14 : 0.28), radius: 10, x: 0, y: 5)
        }
    }

    private func gradientPair(for style: ActionStyle) -> [Color] {
        switch style {
        case .primary:
            return [Color.appPrimary, Color.appAccent.opacity(0.92)]
        case .accent:
            return [Color.appAccent, Color.appPrimary.opacity(0.85)]
        case .neutral:
            return [Color.appSurface, Color.appSurface.opacity(0.68)]
        }
    }
}
