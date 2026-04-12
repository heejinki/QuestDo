//
//  TodoStore.swift
//  prac
//
//  할일 CRUD + 로컬 저장
//

import SwiftUI

// MARK: - 할일 저장소

@Observable
class TodoStore {
    var items: [TodoItem] = []

    private let saveKey = "todo_items"

    /// 할일 완료 시 지급되는 고정 XP
    static let xpPerTodo = 10

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
        return Double(dayTodos.filter(\.isDone).count) / Double(dayTodos.count)
    }

    // MARK: 추가

    /// 할일 추가 (최소 2글자, 하루 최대 20개)
    func add(title: String, date: Date) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return false }
        guard todos(for: date).count < 20 else { return false }

        items.append(TodoItem(title: trimmed, date: date))
        save()
        return true
    }

    // MARK: 완료 처리

    /// 할일 완료. 생성 후 10초 이내 완료 불가.
    /// 반환값: 지급할 XP (완료 성공 시 xpPerTodo, 실패 시 0)
    func complete(_ id: UUID) -> Int {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return 0 }
        guard !items[index].isDone else { return 0 }

        items[index].isDone = true
        items[index].completedAt = Date()
        save()
        return Self.xpPerTodo
    }

    // MARK: 완료 취소

    func uncomplete(_ id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        guard items[index].isDone else { return }

        items[index].isDone = false
        items[index].completedAt = nil
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
