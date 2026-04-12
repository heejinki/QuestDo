//
//  AchievementTitle.swift
//  prac
//
//  칭호(해시태그) 시스템
//

import Foundation

// MARK: - 칭호 카테고리

enum TitleCategory: String, CaseIterable, Identifiable {
    case completion = "완료"
    case streak = "연속"
    case level = "레벨"
    case xp = "경험치"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .completion: "checkmark.circle.fill"
        case .streak:     "flame.fill"
        case .level:      "arrow.up.circle.fill"
        case .xp:         "star.fill"
        }
    }
}

// MARK: - 칭호 정의

struct AchievementTitle: Identifiable {
    let id: String
    let name: String         // 칭호 이름 (해시태그 형식)
    let description: String
    let icon: String
    let category: TitleCategory
    let condition: (UserProfile) -> Bool
}

// MARK: - 칭호 카탈로그 (~50개)

enum TitleCatalog {
    static let all: [AchievementTitle] = completion + streak + level + xp

    // 완료 칭호 (14개)
    static let completion: [AchievementTitle] = [
        AchievementTitle(id: "tc_1",    name: "#첫발을내딛다",   description: "할일 1개 완료",    icon: "figure.walk",             category: .completion, condition: { $0.completedCount >= 1 }),
        AchievementTitle(id: "tc_3",    name: "#세걸음",         description: "할일 3개 완료",    icon: "figure.walk.circle",      category: .completion, condition: { $0.completedCount >= 3 }),
        AchievementTitle(id: "tc_5",    name: "#성실한하루",     description: "할일 5개 완료",    icon: "sun.max.fill",            category: .completion, condition: { $0.completedCount >= 5 }),
        AchievementTitle(id: "tc_10",   name: "#할일초보자",     description: "할일 10개 완료",   icon: "flame",                   category: .completion, condition: { $0.completedCount >= 10 }),
        AchievementTitle(id: "tc_20",   name: "#습관메이커",     description: "할일 20개 완료",   icon: "bolt",                    category: .completion, condition: { $0.completedCount >= 20 }),
        AchievementTitle(id: "tc_30",   name: "#목표추구자",     description: "할일 30개 완료",   icon: "bolt.fill",               category: .completion, condition: { $0.completedCount >= 30 }),
        AchievementTitle(id: "tc_50",   name: "#실행가",         description: "할일 50개 완료",   icon: "star",                    category: .completion, condition: { $0.completedCount >= 50 }),
        AchievementTitle(id: "tc_75",   name: "#포기모름",       description: "할일 75개 완료",   icon: "star.leadinghalf.filled", category: .completion, condition: { $0.completedCount >= 75 }),
        AchievementTitle(id: "tc_100",  name: "#목표달성자",     description: "할일 100개 완료",  icon: "star.fill",               category: .completion, condition: { $0.completedCount >= 100 }),
        AchievementTitle(id: "tc_200",  name: "#이백고지",       description: "할일 200개 완료",  icon: "trophy",                  category: .completion, condition: { $0.completedCount >= 200 }),
        AchievementTitle(id: "tc_300",  name: "#삼백돌파",       description: "할일 300개 완료",  icon: "trophy.fill",             category: .completion, condition: { $0.completedCount >= 300 }),
        AchievementTitle(id: "tc_500",  name: "#오백의탑",       description: "할일 500개 완료",  icon: "medal.fill",              category: .completion, condition: { $0.completedCount >= 500 }),
        AchievementTitle(id: "tc_750",  name: "#전설의시작",     description: "할일 750개 완료",  icon: "crown",                   category: .completion, condition: { $0.completedCount >= 750 }),
        AchievementTitle(id: "tc_1000", name: "#천개의여정",     description: "할일 1000개 완료", icon: "crown.fill",              category: .completion, condition: { $0.completedCount >= 1000 }),
    ]

    // 연속 칭호 (14개)
    static let streak: [AchievementTitle] = [
        AchievementTitle(id: "ts_2",   name: "#이틀연속",    description: "2일 연속 달성",   icon: "2.circle.fill",       category: .streak, condition: { $0.currentStreak >= 2 }),
        AchievementTitle(id: "ts_3",   name: "#사흘연속",    description: "3일 연속 달성",   icon: "3.circle.fill",       category: .streak, condition: { $0.currentStreak >= 3 }),
        AchievementTitle(id: "ts_5",   name: "#닷새연속",    description: "5일 연속 달성",   icon: "bolt",                category: .streak, condition: { $0.currentStreak >= 5 }),
        AchievementTitle(id: "ts_7",   name: "#꾸준함의시작",description: "7일 연속 달성",   icon: "bolt.fill",           category: .streak, condition: { $0.currentStreak >= 7 }),
        AchievementTitle(id: "ts_10",  name: "#열흘연속",    description: "10일 연속 달성",  icon: "bolt.shield",         category: .streak, condition: { $0.currentStreak >= 10 }),
        AchievementTitle(id: "ts_14",  name: "#2주챌린지",   description: "14일 연속 달성",  icon: "bolt.shield.fill",    category: .streak, condition: { $0.currentStreak >= 14 }),
        AchievementTitle(id: "ts_21",  name: "#3주불꽃",     description: "21일 연속 달성",  icon: "flame",               category: .streak, condition: { $0.currentStreak >= 21 }),
        AchievementTitle(id: "ts_30",  name: "#한달연속",    description: "30일 연속 달성",  icon: "flame.fill",          category: .streak, condition: { $0.currentStreak >= 30 }),
        AchievementTitle(id: "ts_45",  name: "#끄떡없어",    description: "45일 연속 달성",  icon: "shield",              category: .streak, condition: { $0.currentStreak >= 45 }),
        AchievementTitle(id: "ts_60",  name: "#두달연속",    description: "60일 연속 달성",  icon: "shield.fill",         category: .streak, condition: { $0.currentStreak >= 60 }),
        AchievementTitle(id: "ts_90",  name: "#꾸준함의힘",  description: "90일 연속 달성",  icon: "shield.lefthalf.filled", category: .streak, condition: { $0.currentStreak >= 90 }),
        AchievementTitle(id: "ts_100", name: "#백일기도",    description: "100일 연속 달성", icon: "shield.checkered",    category: .streak, condition: { $0.currentStreak >= 100 }),
        AchievementTitle(id: "ts_180", name: "#멈출수없는",  description: "180일 연속 달성", icon: "crown",               category: .streak, condition: { $0.currentStreak >= 180 }),
        AchievementTitle(id: "ts_365", name: "#철의의지",    description: "365일 연속 달성", icon: "crown.fill",          category: .streak, condition: { $0.currentStreak >= 365 }),
    ]

    // 레벨 칭호 (12개)
    static let level: [AchievementTitle] = [
        AchievementTitle(id: "tl_2",  name: "#레벨업",      description: "레벨 2 달성",  icon: "arrow.up.circle",      category: .level, condition: { $0.level >= 2 }),
        AchievementTitle(id: "tl_5",  name: "#성장중",      description: "레벨 5 달성",  icon: "arrow.up.circle.fill", category: .level, condition: { $0.level >= 5 }),
        AchievementTitle(id: "tl_7",  name: "#잘하고있어",  description: "레벨 7 달성",  icon: "sparkle",              category: .level, condition: { $0.level >= 7 }),
        AchievementTitle(id: "tl_10", name: "#숙련자",      description: "레벨 10 달성", icon: "sparkles",             category: .level, condition: { $0.level >= 10 }),
        AchievementTitle(id: "tl_15", name: "#상급자",      description: "레벨 15 달성", icon: "star.circle",          category: .level, condition: { $0.level >= 15 }),
        AchievementTitle(id: "tl_20", name: "#떠오르는별",  description: "레벨 20 달성", icon: "star.circle.fill",     category: .level, condition: { $0.level >= 20 }),
        AchievementTitle(id: "tl_25", name: "#베테랑",      description: "레벨 25 달성", icon: "medal",                category: .level, condition: { $0.level >= 25 }),
        AchievementTitle(id: "tl_30", name: "#고수",        description: "레벨 30 달성", icon: "medal.fill",           category: .level, condition: { $0.level >= 30 }),
        AchievementTitle(id: "tl_40", name: "#전문가",      description: "레벨 40 달성", icon: "trophy",               category: .level, condition: { $0.level >= 40 }),
        AchievementTitle(id: "tl_50", name: "#그랜드마스터",description: "레벨 50 달성", icon: "trophy.fill",          category: .level, condition: { $0.level >= 50 }),
        AchievementTitle(id: "tl_75", name: "#레전드",      description: "레벨 75 달성", icon: "crown",                category: .level, condition: { $0.level >= 75 }),
        AchievementTitle(id: "tl_100",name: "#신의경지",    description: "레벨 100 달성",icon: "crown.fill",           category: .level, condition: { $0.level >= 100 }),
    ]

    // 경험치 칭호 (12개)
    static let xp: [AchievementTitle] = [
        AchievementTitle(id: "tx_100",   name: "#XP모으기시작", description: "총 XP 100 달성",    icon: "star",             category: .xp, condition: { $0.totalXP >= 100 }),
        AchievementTitle(id: "tx_300",   name: "#XP수집가",    description: "총 XP 300 달성",    icon: "star.fill",        category: .xp, condition: { $0.totalXP >= 300 }),
        AchievementTitle(id: "tx_500",   name: "#XP탐험가",    description: "총 XP 500 달성",    icon: "star.circle",      category: .xp, condition: { $0.totalXP >= 500 }),
        AchievementTitle(id: "tx_1000",  name: "#XP고수",      description: "총 XP 1000 달성",   icon: "star.circle.fill", category: .xp, condition: { $0.totalXP >= 1000 }),
        AchievementTitle(id: "tx_2000",  name: "#XP마스터",    description: "총 XP 2000 달성",   icon: "trophy",           category: .xp, condition: { $0.totalXP >= 2000 }),
        AchievementTitle(id: "tx_3000",  name: "#XP달인",      description: "총 XP 3000 달성",   icon: "trophy.fill",      category: .xp, condition: { $0.totalXP >= 3000 }),
        AchievementTitle(id: "tx_5000",  name: "#XP천재",      description: "총 XP 5000 달성",   icon: "medal",            category: .xp, condition: { $0.totalXP >= 5000 }),
        AchievementTitle(id: "tx_7500",  name: "#XP신화",      description: "총 XP 7500 달성",   icon: "medal.fill",       category: .xp, condition: { $0.totalXP >= 7500 }),
        AchievementTitle(id: "tx_10000", name: "#만XP돌파",    description: "총 XP 10000 달성",  icon: "crown",            category: .xp, condition: { $0.totalXP >= 10000 }),
        AchievementTitle(id: "tx_20000", name: "#XP전설",      description: "총 XP 20000 달성",  icon: "crown.fill",       category: .xp, condition: { $0.totalXP >= 20000 }),
        AchievementTitle(id: "tx_50000", name: "#XP신",        description: "총 XP 50000 달성",  icon: "sparkles",         category: .xp, condition: { $0.totalXP >= 50000 }),
        AchievementTitle(id: "tx_100000",name: "#XP초월자",    description: "총 XP 100000 달성", icon: "sparkle",          category: .xp, condition: { $0.totalXP >= 100000 }),
    ]
}
