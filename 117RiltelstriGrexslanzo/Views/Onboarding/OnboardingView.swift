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
                onboardingPage(title: "Learn Through Play", subtitle: "Explore logic, shapes, and colors in short fun challenges.", index: 0)
                    .tag(0)
                onboardingPage(title: "Track Your Progress", subtitle: "Collect stars and unlock new levels as you improve.", index: 1)
                    .tag(1)
                onboardingPage(title: "Grow Every Day", subtitle: "Practice, retry, and build stronger thinking skills.", index: 2)
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
                Text(page == 2 ? "Start Learning" : "Next")
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
            OnboardingIllustrationView(index: index)
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

private struct OnboardingIllustrationView: View {
    let index: Int
    @State private var animate = false

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let progress = animate ? 1.0 : 0.2
            let baseY = h * (0.45 + 0.05 * sin(progress * .pi))

            var path = Path()
            path.move(to: CGPoint(x: w * 0.1, y: baseY))
            path.addCurve(to: CGPoint(x: w * 0.9, y: baseY),
                          control1: CGPoint(x: w * 0.3, y: baseY - 50 * progress),
                          control2: CGPoint(x: w * 0.7, y: baseY + 50 * progress))
            context.stroke(path, with: .color(Color.appAccent), lineWidth: 8)

            let circles = 3 + index
            for i in 0..<circles {
                let x = w * (0.18 + Double(i) * 0.18)
                let y = h * (0.2 + 0.12 * Double((i + index) % 3))
                let r = 18 + CGFloat(i * 2)
                let circle = Path(ellipseIn: CGRect(x: x, y: y + CGFloat(20 * (1 - progress)), width: r, height: r))
                context.fill(circle, with: .color(Color.appPrimary.opacity(0.6 + 0.1 * Double(i))))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
