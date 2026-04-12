//
//  GlassModifier.swift
//  prac
//
//  리퀴드 글래스 스타일 재사용 컴포넌트
//

import SwiftUI

// MARK: - 글래스 카드 수식어

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    var opacity: Double = 1.0

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.1),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
            .opacity(opacity)
    }
}

// MARK: - View 확장 (간편 호출)

extension View {
    func glassCard(cornerRadius: CGFloat = 16, opacity: Double = 1.0) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - 앱 전체 배경 그라데이션

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.12),
                Color.purple.opacity(0.08),
                Color.pink.opacity(0.05),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
