//
//  TodoItem.swift
//  prac
//
//  할일 데이터 모델
//

import Foundation

// MARK: - 검수 상태

enum ReviewStatus: String, Codable {
    case none              // 미완료 상태
    case autoApproved      // 자동 승인 (쉬움 난이도)
    case pendingReview     // 검수 대기 중
    case approved          // 검수 승인 → XP 지급됨
    case rejected          // 검수 거절 → XP 미지급

    var label: String {
        switch self {
        case .none: "미완료"
        case .autoApproved: "자동 승인"
        case .pendingReview: "검수 대기"
        case .approved: "승인 완료"
        case .rejected: "거절됨"
        }
    }

    var icon: String {
        switch self {
        case .none: "circle"
        case .autoApproved: "checkmark.circle.fill"
        case .pendingReview: "clock.fill"
        case .approved: "checkmark.seal.fill"
        case .rejected: "xmark.seal.fill"
        }
    }

    var color: String {
        switch self {
        case .none: "gray"
        case .autoApproved: "green"
        case .pendingReview: "orange"
        case .approved: "blue"
        case .rejected: "red"
        }
    }
}

// MARK: - 할일 항목

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isDone: Bool
    var date: Date
    var difficulty: Difficulty
    var createdAt: Date
    var completedAt: Date?

    // 검수 관련
    var reviewStatus: ReviewStatus
    var completionNote: String      // 완료 시 후기/증빙 메모
    var reviewerComment: String?    // 검수자 코멘트
    var reviewedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        difficulty: Difficulty = .medium,
        isDone: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        reviewStatus: ReviewStatus = .none,
        completionNote: String = ""
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.difficulty = difficulty
        self.isDone = isDone
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.reviewStatus = reviewStatus
        self.completionNote = completionNote
    }

    /// 검수가 필요한 난이도인지
    var needsReview: Bool {
        difficulty != .easy
    }
}

// MARK: - 난이도 (획득 XP 결정)

enum Difficulty: Int, Codable, CaseIterable, Identifiable {
    case easy = 10
    case medium = 25
    case hard = 50

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .easy: "쉬움"
        case .medium: "보통"
        case .hard: "어려움"
        }
    }

    var icon: String {
        switch self {
        case .easy: "star"
        case .medium: "star.leadinghalf.filled"
        case .hard: "star.fill"
        }
    }

    var xp: Int { rawValue }

    /// 검수 XP (검수자가 받는 XP)
    var reviewXP: Int {
        switch self {
        case .easy: 0       // 자동 승인이라 검수 없음
        case .medium: 5
        case .hard: 10
        }
    }
}
