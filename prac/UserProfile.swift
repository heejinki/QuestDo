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
    var nickname: String = ""
    var age: Int? = nil
    var gender: Gender? = nil
    var profileImageData: Data? = nil

    var totalXP: Int = 0
    var completedCount: Int = 0
    var currentStreak: Int = 0
    var lastActiveDate: Date? = nil
    var unlockedBadgeIDs: Set<String> = []

    var isProfileSet: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var level: Int { totalXP / 100 + 1 }
    var currentLevelXP: Int { totalXP % 100 }
    var xpForNextLevel: Int { 100 }
    var levelProgress: Double { Double(currentLevelXP) / Double(xpForNextLevel) }
}

// MARK: - 뱃지 카테고리

enum BadgeCategory: String, CaseIterable, Identifiable {
    case completion = "완료"
    case streak = "연속"
    case level = "레벨"
    case xp = "경험치"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .completion: "checkmark.circle.fill"
        case .streak: "flame.fill"
        case .level: "arrow.up.circle.fill"
        case .xp: "star.fill"
        }
    }
}

// MARK: - 뱃지 정의

struct Badge: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: BadgeCategory
    let condition: (UserProfile) -> Bool
}

// MARK: - 뱃지 카탈로그 (~50개)

enum BadgeCatalog {
    static let all: [Badge] = completion + streak + level + xp

    // 완료 달성 뱃지 (18개)
    static let completion: [Badge] = [
        Badge(id: "c_1",    name: "첫 걸음",        description: "할일 1개 완료",    icon: "figure.walk",             category: .completion, condition: { $0.completedCount >= 1 }),
        Badge(id: "c_2",    name: "두 번째 도전",    description: "할일 2개 완료",    icon: "figure.walk.circle",      category: .completion, condition: { $0.completedCount >= 2 }),
        Badge(id: "c_3",    name: "삼세번",          description: "할일 3개 완료",    icon: "3.circle.fill",           category: .completion, condition: { $0.completedCount >= 3 }),
        Badge(id: "c_5",    name: "다섯 고개",       description: "할일 5개 완료",    icon: "5.circle.fill",           category: .completion, condition: { $0.completedCount >= 5 }),
        Badge(id: "c_7",    name: "행운의 숫자",     description: "할일 7개 완료",    icon: "7.circle.fill",           category: .completion, condition: { $0.completedCount >= 7 }),
        Badge(id: "c_10",   name: "두 자릿수",       description: "할일 10개 완료",   icon: "flame",                   category: .completion, condition: { $0.completedCount >= 10 }),
        Badge(id: "c_15",   name: "꾸준한 시작",     description: "할일 15개 완료",   icon: "flame.fill",              category: .completion, condition: { $0.completedCount >= 15 }),
        Badge(id: "c_20",   name: "습관 형성 중",    description: "할일 20개 완료",   icon: "bolt",                    category: .completion, condition: { $0.completedCount >= 20 }),
        Badge(id: "c_30",   name: "한 달치 목표",    description: "할일 30개 완료",   icon: "bolt.fill",               category: .completion, condition: { $0.completedCount >= 30 }),
        Badge(id: "c_50",   name: "절반의 성공",     description: "할일 50개 완료",   icon: "star",                    category: .completion, condition: { $0.completedCount >= 50 }),
        Badge(id: "c_75",   name: "꺾이지 않는 마음",description: "할일 75개 완료",   icon: "star.leadinghalf.filled", category: .completion, condition: { $0.completedCount >= 75 }),
        Badge(id: "c_100",  name: "세 자릿수",       description: "할일 100개 완료",  icon: "star.fill",               category: .completion, condition: { $0.completedCount >= 100 }),
        Badge(id: "c_150",  name: "목표 달성가",     description: "할일 150개 완료",  icon: "trophy",                  category: .completion, condition: { $0.completedCount >= 150 }),
        Badge(id: "c_200",  name: "이백 고지",       description: "할일 200개 완료",  icon: "trophy.fill",             category: .completion, condition: { $0.completedCount >= 200 }),
        Badge(id: "c_300",  name: "끝없는 도전",     description: "할일 300개 완료",  icon: "medal",                   category: .completion, condition: { $0.completedCount >= 300 }),
        Badge(id: "c_500",  name: "오백의 탑",       description: "할일 500개 완료",  icon: "medal.fill",              category: .completion, condition: { $0.completedCount >= 500 }),
        Badge(id: "c_750",  name: "전설의 시작",     description: "할일 750개 완료",  icon: "crown",                   category: .completion, condition: { $0.completedCount >= 750 }),
        Badge(id: "c_1000", name: "천 개의 이정표",  description: "할일 1000개 완료", icon: "crown.fill",              category: .completion, condition: { $0.completedCount >= 1000 }),
    ]

    // 연속 달성 뱃지 (12개)
    static let streak: [Badge] = [
        Badge(id: "s_2",   name: "이틀 연속",    description: "2일 연속 달성",   icon: "2.circle.fill",      category: .streak, condition: { $0.currentStreak >= 2 }),
        Badge(id: "s_3",   name: "삼일 연속",    description: "3일 연속 달성",   icon: "3.circle.fill",      category: .streak, condition: { $0.currentStreak >= 3 }),
        Badge(id: "s_5",   name: "닷새 연속",    description: "5일 연속 달성",   icon: "bolt",               category: .streak, condition: { $0.currentStreak >= 5 }),
        Badge(id: "s_7",   name: "일주일 챌린지",description: "7일 연속 달성",   icon: "bolt.fill",          category: .streak, condition: { $0.currentStreak >= 7 }),
        Badge(id: "s_10",  name: "열흘 고지",    description: "10일 연속 달성",  icon: "bolt.shield",        category: .streak, condition: { $0.currentStreak >= 10 }),
        Badge(id: "s_14",  name: "2주 연속",     description: "14일 연속 달성",  icon: "bolt.shield.fill",   category: .streak, condition: { $0.currentStreak >= 14 }),
        Badge(id: "s_21",  name: "3주 불꽃",     description: "21일 연속 달성",  icon: "flame",              category: .streak, condition: { $0.currentStreak >= 21 }),
        Badge(id: "s_30",  name: "한 달 불꽃",   description: "30일 연속 달성",  icon: "flame.fill",         category: .streak, condition: { $0.currentStreak >= 30 }),
        Badge(id: "s_50",  name: "오십일의 기적",description: "50일 연속 달성",  icon: "shield",             category: .streak, condition: { $0.currentStreak >= 50 }),
        Badge(id: "s_60",  name: "두 달 연속",   description: "60일 연속 달성",  icon: "shield.fill",        category: .streak, condition: { $0.currentStreak >= 60 }),
        Badge(id: "s_90",  name: "삼 개월의 힘", description: "90일 연속 달성",  icon: "shield.lefthalf.filled", category: .streak, condition: { $0.currentStreak >= 90 }),
        Badge(id: "s_100", name: "백일 기도",    description: "100일 연속 달성", icon: "shield.checkered",   category: .streak, condition: { $0.currentStreak >= 100 }),
    ]

    // 레벨 뱃지 (12개)
    static let level: [Badge] = [
        Badge(id: "l_2",  name: "레벨 2",      description: "레벨 2 달성",  icon: "2.square.fill",         category: .level, condition: { $0.level >= 2 }),
        Badge(id: "l_3",  name: "레벨 3",      description: "레벨 3 달성",  icon: "3.square.fill",         category: .level, condition: { $0.level >= 3 }),
        Badge(id: "l_5",  name: "성장 중",     description: "레벨 5 달성",  icon: "arrow.up.circle",       category: .level, condition: { $0.level >= 5 }),
        Badge(id: "l_7",  name: "레벨 7",      description: "레벨 7 달성",  icon: "arrow.up.circle.fill",  category: .level, condition: { $0.level >= 7 }),
        Badge(id: "l_10", name: "두 자리 레벨",description: "레벨 10 달성", icon: "sparkles",              category: .level, condition: { $0.level >= 10 }),
        Badge(id: "l_12", name: "레벨 12",     description: "레벨 12 달성", icon: "sparkle",               category: .level, condition: { $0.level >= 12 }),
        Badge(id: "l_15", name: "레벨 15",     description: "레벨 15 달성", icon: "star.circle",           category: .level, condition: { $0.level >= 15 }),
        Badge(id: "l_20", name: "레벨 20",     description: "레벨 20 달성", icon: "star.circle.fill",      category: .level, condition: { $0.level >= 20 }),
        Badge(id: "l_25", name: "베테랑",      description: "레벨 25 달성", icon: "medal",                 category: .level, condition: { $0.level >= 25 }),
        Badge(id: "l_30", name: "레벨 30",     description: "레벨 30 달성", icon: "medal.fill",            category: .level, condition: { $0.level >= 30 }),
        Badge(id: "l_40", name: "레벨 40",     description: "레벨 40 달성", icon: "crown",                 category: .level, condition: { $0.level >= 40 }),
        Badge(id: "l_50", name: "레벨 50 마스터",description: "레벨 50 달성",icon: "crown.fill",           category: .level, condition: { $0.level >= 50 }),
    ]

    // 경험치 뱃지 (8개)
    static let xp: [Badge] = [
        Badge(id: "x_100",   name: "첫 100 XP",  description: "총 XP 100 달성",   icon: "star",              category: .xp, condition: { $0.totalXP >= 100 }),
        Badge(id: "x_250",   name: "250 XP",     description: "총 XP 250 달성",   icon: "star.fill",         category: .xp, condition: { $0.totalXP >= 250 }),
        Badge(id: "x_500",   name: "500 XP",     description: "총 XP 500 달성",   icon: "star.circle",       category: .xp, condition: { $0.totalXP >= 500 }),
        Badge(id: "x_1000",  name: "1000 XP",    description: "총 XP 1000 달성",  icon: "star.circle.fill",  category: .xp, condition: { $0.totalXP >= 1000 }),
        Badge(id: "x_2000",  name: "2000 XP",    description: "총 XP 2000 달성",  icon: "trophy",            category: .xp, condition: { $0.totalXP >= 2000 }),
        Badge(id: "x_5000",  name: "5000 XP",    description: "총 XP 5000 달성",  icon: "trophy.fill",       category: .xp, condition: { $0.totalXP >= 5000 }),
        Badge(id: "x_10000", name: "만 XP",      description: "총 XP 10000 달성", icon: "crown",             category: .xp, condition: { $0.totalXP >= 10000 }),
        Badge(id: "x_50000", name: "전설의 XP",  description: "총 XP 50000 달성", icon: "crown.fill",        category: .xp, condition: { $0.totalXP >= 50000 }),
    ]
}
