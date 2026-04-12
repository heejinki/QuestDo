//
//  UserProfile.swift
//  prac
//
//  유저 프로필 (경험치, 레벨, 뱃지)
//

import Foundation

// MARK: - 유저 프로필

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "남성"
    case female = "여성"
    case other = "기타"

    var id: String { rawValue }
}

struct UserProfile: Codable {
    // 프로필 정보
    var nickname: String = ""
    var age: Int? = nil
    var gender: Gender? = nil
    var profileImageData: Data? = nil  // 프로필 사진 (JPEG 데이터)

    // 경험치/업적
    var totalXP: Int = 0
    var completedCount: Int = 0
    var currentStreak: Int = 0       // 연속 달성 일수
    var lastActiveDate: Date? = nil
    var unlockedBadgeIDs: Set<String> = []

    /// 프로필 설정 완료 여부
    var isProfileSet: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: 레벨 계산

    /// 현재 레벨 (100XP당 1레벨)
    var level: Int {
        totalXP / 100 + 1
    }

    /// 현재 레벨 내 진행 XP
    var currentLevelXP: Int {
        totalXP % 100
    }

    /// 다음 레벨까지 필요한 총 XP
    var xpForNextLevel: Int { 100 }

    /// 레벨업 진행률 (0.0 ~ 1.0)
    var levelProgress: Double {
        Double(currentLevelXP) / Double(xpForNextLevel)
    }
}

// MARK: - 뱃지 정의

struct Badge: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String        // SF Symbol 이름

    /// 해금 조건 판별
    let condition: (UserProfile) -> Bool
}

// MARK: - 뱃지 목록 (중앙 관리)

enum BadgeCatalog {
    static let all: [Badge] = [
        Badge(
            id: "first_clear",
            name: "첫 걸음",
            description: "할일을 처음으로 완료",
            icon: "figure.walk",
            condition: { $0.completedCount >= 1 }
        ),
        Badge(
            id: "ten_clear",
            name: "꾸준한 실행자",
            description: "할일 10개 완료",
            icon: "flame",
            condition: { $0.completedCount >= 10 }
        ),
        Badge(
            id: "fifty_clear",
            name: "목표 달성가",
            description: "할일 50개 완료",
            icon: "trophy",
            condition: { $0.completedCount >= 50 }
        ),
        Badge(
            id: "streak_3",
            name: "3일 연속",
            description: "3일 연속 할일 완료",
            icon: "bolt.fill",
            condition: { $0.currentStreak >= 3 }
        ),
        Badge(
            id: "streak_7",
            name: "일주일 챌린지",
            description: "7일 연속 할일 완료",
            icon: "bolt.shield.fill",
            condition: { $0.currentStreak >= 7 }
        ),
        Badge(
            id: "level_5",
            name: "성장 중",
            description: "레벨 5 달성",
            icon: "arrow.up.circle.fill",
            condition: { $0.level >= 5 }
        ),
        Badge(
            id: "level_10",
            name: "베테랑",
            description: "레벨 10 달성",
            icon: "crown.fill",
            condition: { $0.level >= 10 }
        ),
    ]
}
