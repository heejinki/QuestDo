//
//  SplashView.swift
//  prac
//
//  앱 실행 시 스플래시 화면
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.2),
                    Color.purple.opacity(0.15),
                    Color.pink.opacity(0.1),
                    Color.blue.opacity(0.08),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // 로고 아이콘
                ZStack {
                    // 외곽 글래스 원
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.8),
                                            .blue.opacity(0.3),
                                            .purple.opacity(0.3),
                                            .white.opacity(0.5),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .blue.opacity(0.2), radius: 20, y: 10)

                    // 아이콘
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // 빛 반사 효과
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .frame(width: 120, height: 120)
                        .mask(
                            Circle().frame(width: 120, height: 120)
                        )
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // 앱 이름
                VStack(spacing: 6) {
                    Text("QuestDo")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("할일을 퀘스트로, 일상을 모험으로")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(titleOpacity)
            }
        }
        .onAppear {
            // 로고 등장 애니메이션
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            // 타이틀 페이드인
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                titleOpacity = 1.0
            }
        }
    }
}
