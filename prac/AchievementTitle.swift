//
//  AchievementTitle.swift
//  prac
//
//  유저 칭호/해시태그 시스템 (랭킹에서 표시)
//

import Foundation

// MARK: - 칭호 정의

struct AchievementTitle: Identifiable {
    let id: String
    let name: String         // 칭호 이름 (해시태그)
    let description: String
    let icon: String
    let category: TitleCategory

    /// 해금 조건
    let condition: (UserProfile, TitleStats) -> Bool
}

enum TitleCategory: String, CaseIterable, Identifiable {
    case completion = "완료"
    case review = "검수"
    case streak = "연속"
    case level = "레벨"

    var id: String { rawValue }
}

/// 칭호 판별에 필요한 추가 통계
struct TitleStats: Codable {
    var hardCompletedCount: Int = 0   // 어려움 완료 수
    var reviewedCount: Int = 0        // 검수 수행 횟수
    var hardReviewedCount: Int = 0    // 어려움 검수 수행 횟수

    private static let saveKey = "title_stats"

    static func load() -> TitleStats {
        guard let data = UserDefaults.standard.data(forKey: Self.saveKey),
              let decoded = try? JSONDecoder().decode(TitleStats.self, from: data)
        else { return TitleStats() }
        return decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.saveKey)
    }
}

// MARK: - 칭호 카탈로그

enum TitleCatalog {
    static let all: [AchievementTitle] = [
        // 완료 관련
        AchievementTitle(
            id: "t_first_step",
            name: "#첫발을내딛다",
            description: "첫 번째 할일 완료",
            icon: "figure.walk",
            category: .completion,
            condition: { profile, _ in profile.completedCount >= 1 }
        ),
        AchievementTitle(
            id: "t_doer",
            name: "#실행가",
            description: "할일 30개 완료",
            icon: "bolt.fill",
            category: .completion,
            condition: { profile, _ in profile.completedCount >= 30 }
        ),
        AchievementTitle(
            id: "t_achiever",
            name: "#목표달성자",
            description: "할일 100개 완료",
            icon: "trophy",
            category: .completion,
            condition: { profile, _ in profile.completedCount >= 100 }
        ),
        AchievementTitle(
            id: "t_legend",
            name: "#전설의시작",
            description: "할일 500개 완료",
            icon: "crown.fill",
            category: .completion,
            condition: { profile, _ in profile.completedCount >= 500 }
        ),
        AchievementTitle(
            id: "t_hard_challenger",
            name: "#도전자",
            description: "어려움 할일 10개 완료",
            icon: "flame",
            category: .completion,
            condition: { _, stats in stats.hardCompletedCount >= 10 }
        ),
        AchievementTitle(
            id: "t_hard_master",
            name: "#할일마스터",
            description: "어려움 할일 100개 완료 + 검수 성공",
            icon: "star.circle.fill",
            category: .completion,
            condition: { _, stats in stats.hardCompletedCount >= 100 }
        ),

        // 검수 관련
        AchievementTitle(
            id: "t_reviewer",
            name: "#검수원",
            description: "검수 10회 수행",
            icon: "magnifyingglass",
            category: .review,
            condition: { _, stats in stats.reviewedCount >= 10 }
        ),
        AchievementTitle(
            id: "t_inspector",
            name: "#수석검수관",
            description: "검수 50회 수행",
            icon: "checkmark.seal.fill",
            category: .review,
            condition: { _, stats in stats.reviewedCount >= 50 }
        ),
        AchievementTitle(
            id: "t_hard_inspector",
            name: "#엄격한심사관",
            description: "어려움 할일 검수 30회",
            icon: "eye.fill",
            category: .review,
            condition: { _, stats in stats.hardReviewedCount >= 30 }
        ),

        // 연속 관련
        AchievementTitle(
            id: "t_steady",
            name: "#꾸준함의힘",
            description: "7일 연속 달성",
            icon: "bolt.shield.fill",
            category: .streak,
            condition: { profile, _ in profile.currentStreak >= 7 }
        ),
        AchievementTitle(
            id: "t_unstoppable",
            name: "#멈출수없는",
            description: "30일 연속 달성",
            icon: "flame.circle.fill",
            category: .streak,
            condition: { profile, _ in profile.currentStreak >= 30 }
        ),
        AchievementTitle(
            id: "t_iron_will",
            name: "#철의의지",
            description: "100일 연속 달성",
            icon: "shield.fill",
            category: .streak,
            condition: { profile, _ in profile.currentStreak >= 100 }
        ),

        // 레벨 관련
        AchievementTitle(
            id: "t_rising",
            name: "#떠오르는별",
            description: "레벨 10 달성",
            icon: "sparkles",
            category: .level,
            condition: { profile, _ in profile.level >= 10 }
        ),
        AchievementTitle(
            id: "t_veteran",
            name: "#베테랑",
            description: "레벨 25 달성",
            icon: "medal.fill",
            category: .level,
            condition: { profile, _ in profile.level >= 25 }
        ),
        AchievementTitle(
            id: "t_grandmaster",
            name: "#그랜드마스터",
            description: "레벨 50 달성",
            icon: "crown.fill",
            category: .level,
            condition: { profile, _ in profile.level >= 50 }
        ),
    ]
}
