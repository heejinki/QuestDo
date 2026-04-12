//
//  TodoItem.swift
//  prac
//
//  할일 데이터 모델
//

import Foundation

// MARK: - 할일 항목

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isDone: Bool
    var date: Date
    var createdAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        isDone: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.isDone = isDone
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
