//
//  TodoStore.swift
//  prac
//
//  할일 CRUD + 검수 관리 + 로컬 저장
//

import SwiftUI

// MARK: - 할일 저장소

@Observable
class TodoStore {
    var items: [TodoItem] = []

    private let saveKey = "todo_items"

    init() {
        load()
    }

    // MARK: 조회

    /// 특정 날짜의 할일 목록
    func todos(for date: Date) -> [TodoItem] {
        items.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    /// 특정 날짜에 할일이 존재하는지
    func hasTodos(on date: Date) -> Bool {
        items.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    /// 특정 날짜의 완료율 (0.0 ~ 1.0)
    func completionRate(for date: Date) -> Double {
        let dayTodos = todos(for: date)
        guard !dayTodos.isEmpty else { return 0 }
        let doneCount = dayTodos.filter(\.isDone).count
        return Double(doneCount) / Double(dayTodos.count)
    }

    /// 검수 대기 중인 할일 목록
    var pendingReviewItems: [TodoItem] {
        items.filter { $0.reviewStatus == .pendingReview }
    }

    // MARK: 추가

    /// 할일 추가 (어뷰징 방지: 하루 최대 20개, 최소 2글자)
    func add(title: String, date: Date, difficulty: Difficulty) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= 2 else { return false }
        guard todos(for: date).count < 20 else { return false }

        let item = TodoItem(title: trimmed, date: date, difficulty: difficulty)
        items.append(item)
        save()
        return true
    }

    // MARK: 완료 처리 (검수 시스템 연동)

    /// 할일 완료. 쉬움=자동승인+즉시XP, 보통/어려움=검수대기
    /// 반환값: 즉시 지급할 XP (자동승인일 때만 양수)
    func completeWithReview(_ id: UUID, note: String) -> Int {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return 0 }

        let item = items[index]

        // 이미 완료된 항목은 무시
        guard !item.isDone else { return 0 }

        // 어뷰징 방지: 생성 후 10초 이내 완료 불가
        let elapsed = Date().timeIntervalSince(item.createdAt)
        guard elapsed >= 10 else { return 0 }

        items[index].isDone = true
        items[index].completedAt = Date()
        items[index].completionNote = note

        var xpDelta = 0

        if item.needsReview {
            // 보통/어려움: 검수 대기 상태로 전환
            items[index].reviewStatus = .pendingReview
        } else {
            // 쉬움: 자동 승인, 즉시 XP 지급
            items[index].reviewStatus = .autoApproved
            xpDelta = item.difficulty.xp
        }

        save()
        return xpDelta
    }

    // MARK: 완료 취소

    /// 검수 대기 중이거나 자동승인인 경우만 취소 가능
    func uncomplete(_ id: UUID) -> Int {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return 0 }

        let item = items[index]
        guard item.isDone else { return 0 }

        // 이미 검수 완료된 항목은 취소 불가
        guard item.reviewStatus != .approved else { return 0 }

        var xpDelta = 0
        if item.reviewStatus == .autoApproved {
            xpDelta = -item.difficulty.xp
        }

        items[index].isDone = false
        items[index].completedAt = nil
        items[index].completionNote = ""
        items[index].reviewStatus = .none
        items[index].reviewerComment = nil
        items[index].reviewedAt = nil

        save()
        return xpDelta
    }

    // MARK: 검수 승인

    /// 검수 승인 처리. 승인 시 할일 작성자에게 줄 XP 반환
    func approveReview(_ id: UUID, comment: String) -> Int {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return 0 }
        guard items[index].reviewStatus == .pendingReview else { return 0 }

        items[index].reviewStatus = .approved
        items[index].reviewerComment = comment.isEmpty ? nil : comment
        items[index].reviewedAt = Date()

        save()
        return items[index].difficulty.xp
    }

    // MARK: 검수 거절

    /// 검수 거절 처리. 거절 사유 필수
    func rejectReview(_ id: UUID, comment: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        guard items[index].reviewStatus == .pendingReview else { return }

        items[index].reviewStatus = .rejected
        items[index].reviewerComment = comment
        items[index].reviewedAt = Date()

        save()
    }

    // MARK: 삭제

    func delete(_ id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    // MARK: 로컬 저장/불러오기

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data)
        else { return }
        items = decoded
    }
}
