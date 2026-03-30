//
//  View+AppChrome.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

extension View {
    /// Atmospheric screen background: layered gradients using only asset colors.
    func appScreenBackdrop() -> some View {
        background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.appBackground,
                        Color.appSurface.opacity(0.42),
                        Color.appBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [Color.appAccent.opacity(0.22), Color.clear],
                    center: .topTrailing,
                    startRadius: 20,
                    endRadius: 340
                )
                RadialGradient(
                    colors: [Color.appPrimary.opacity(0.14), Color.clear],
                    center: .bottomLeading,
                    startRadius: 10,
                    endRadius: 320
                )
            }
            .ignoresSafeArea()
        }
    }

    /// Elevated card: gradient fill, rim highlight, soft depth shadows.
    func appPanel(cornerRadius: CGFloat = 18, elevated: Bool = true) -> some View {
        let opacity = elevated ? 0.22 : 0.12
        let radius = elevated ? 16.0 : 10.0
        let y = elevated ? 8.0 : 5.0
        return background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface,
                                Color.appSurface.opacity(0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.appTextPrimary.opacity(0.16),
                                Color.appPrimary.opacity(0.28),
                                Color.appAccent.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.appPrimary.opacity(opacity), radius: radius, x: 0, y: y)
            .shadow(color: Color.appBackground.opacity(0.45), radius: 3, x: 0, y: 1)
        }
    }

    /// Primary CTA: warm gradient + glow shadow.
    func appProminentFill(cornerRadius: CGFloat = 14) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary,
                            Color.appAccent.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.appPrimary.opacity(0.38), radius: 12, x: 0, y: 6)
                .shadow(color: Color.appAccent.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }

    /// Softer inset surface (chips, secondary blocks).
    func appSoftFill(cornerRadius: CGFloat = 14) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.96),
                            Color.appSurface.opacity(0.62)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.appPrimary.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.appPrimary.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }

    /// Playfield / canvas area — slightly recessed, still had depth.
    func appPlayfield(cornerRadius: CGFloat = 18) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.96),
                                Color.appBackground.opacity(0.38)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.appPrimary.opacity(0.2), lineWidth: 1)
            }
            .shadow(color: Color.appBackground.opacity(0.55), radius: 2, x: 0, y: 2)
            .shadow(color: Color.appPrimary.opacity(0.16), radius: 14, x: 0, y: 8)
        }
    }

    /// Selected chip / pill — filled gradient + lift.
    func appSelectedChip(cornerRadius: CGFloat = 12) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appAccent.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.appPrimary.opacity(0.35), radius: 8, x: 0, y: 4)
        }
    }
}
