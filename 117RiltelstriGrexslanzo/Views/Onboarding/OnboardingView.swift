//
//  OnboardingView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var page = 0
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $page) {
                onboardingPage(
                    title: "Playful workshops",
                    subtitle: "Short labs mix logic puzzles, glowing grids, and color forging without feeling like homework.",
                    index: 0
                )
                .tag(0)
                onboardingPage(
                    title: "Your deck, your pace",
                    subtitle: "Sparks mark how cleanly you finish each tier. Locked steps open as you prove consistency.",
                    index: 1
                )
                .tag(1)
                onboardingPage(
                    title: "Keep the streak",
                    subtitle: "Retry, sharpen accuracy, and watch the milestone vault fill with real progress.",
                    index: 2
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: .infinity, alignment: .top)

            Button(action: {
                if page < 2 {
                    withAnimation(.easeInOut(duration: 0.3)) { page += 1 }
                } else {
                    onFinish()
                }
            }) {
                Text(page == 2 ? "Enter the studio" : "Continue")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .appProminentFill(cornerRadius: 14)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .appScreenBackdrop()
    }

    private func onboardingPage(title: String, subtitle: String, index: Int) -> some View {
        VStack(spacing: 20) {
            BloomOnboardingCanvas(index: index)
                .frame(height: 280)
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 8)
        .appPanel(cornerRadius: 20, elevated: false)
        .padding(.top, 24)
    }
}

private struct BloomOnboardingCanvas: View {
    let index: Int
    @State private var animate = false

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let wave = animate ? 1.0 : 0.35
            let midY = h * 0.52

            var ribbon = Path()
            ribbon.move(to: CGPoint(x: w * 0.08, y: midY))
            ribbon.addQuadCurve(
                to: CGPoint(x: w * 0.92, y: midY * 0.92),
                control: CGPoint(x: w * 0.5, y: midY - 70 * wave)
            )
            context.stroke(ribbon, with: .color(Color.appPrimary.opacity(0.75)), lineWidth: 6)

            let markers = 2 + index
            for i in 0..<markers {
                let t = Double(i) / Double(max(1, markers))
                let x = w * (0.22 + t * 0.56)
                let y = h * (0.22 + 0.1 * Double((i + index) % 4)) + CGFloat(18 * (1 - wave))
                let rect = CGRect(x: x, y: y, width: 22 + CGFloat(i * 3), height: 22 + CGFloat(i * 3))
                var diamond = Path()
                diamond.addRoundedRect(in: rect, cornerSize: CGSize(width: 6, height: 6))
                context.fill(
                    diamond,
                    with: .color(Color.appAccent.opacity(0.35 + Double(i) * 0.12))
                )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
