//
//  TodoListView.swift
//  prac
//
//  선택된 날짜의 할일 목록 표시 + 추가/삭제
//

import SwiftUI

struct TodoListView: View {
    var selectedDate: Date
    var todoStore: TodoStore
    var rewardManager: RewardManager

    @State private var newTitle: String = ""
    @State private var showAddForm: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private var todos: [TodoItem] {
        todoStore.todos(for: selectedDate)
    }

    var body: some View {
        VStack(spacing: 12) {
            dateHeader
            todoList
            addButton
        }
    }

    // MARK: - 날짜 헤더

    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("\(todos.count)개의 할일")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            if !todos.isEmpty {
                let doneCount = todos.filter(\.isDone).count
                Text("\(doneCount)/\(todos.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .glassCard(cornerRadius: 8)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - 할일 목록

    private var todoList: some View {
        Group {
            if todos.isEmpty {
                emptyState
            } else {
                VStack(spacing: 8) {
                    ForEach(todos) { item in
                        todoRow(item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("할일이 없습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - 할일 행

    private func todoRow(_ item: TodoItem) -> some View {
        HStack(spacing: 12) {
            // 체크 버튼
            Button {
                handleToggle(item)
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)

            // 할일 제목
            Text(item.title)
                .strikethrough(item.isDone)
                .foregroundStyle(item.isDone ? .secondary : .primary)

            Spacer()

            // 삭제 버튼
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    todoStore.delete(item.id)
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .glassCard(cornerRadius: 12, opacity: item.isDone ? 0.6 : 1.0)
    }

    // MARK: - 완료/취소 토글

    private func handleToggle(_ item: TodoItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if item.isDone {
                todoStore.uncomplete(item.id)
                _ = rewardManager.addXP(-TodoStore.xpPerTodo)
            } else {
                let xp = todoStore.complete(item.id)
                if xp > 0 {
                    _ = rewardManager.addXP(xp)
                }
            }
        }
    }

    // MARK: - 추가 버튼 + 폼

    private var addButton: some View {
        VStack(spacing: 8) {
            if showAddForm {
                addForm
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAddForm.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: showAddForm ? "xmark" : "plus")
                    Text(showAddForm ? "취소" : "할일 추가")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .glassCard(cornerRadius: 12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
        .alert("알림", isPresented: $showError) {
            Button("확인") {}
        } message: {
            Text(errorMessage)
        }
    }

    private var addForm: some View {
        HStack(spacing: 8) {
            TextField("할일을 입력하세요 (2글자 이상)", text: $newTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit { submitTodo() }

            Button {
                submitTodo()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .disabled(newTitle.trimmingCharacters(in: .whitespaces).count < 2)
        }
        .padding(12)
        .glassCard(cornerRadius: 12)
        .padding(.horizontal)
    }

    private func submitTodo() {
        let success = todoStore.add(title: newTitle, date: selectedDate)

        if success {
            newTitle = ""
            showAddForm = false
        } else {
            errorMessage = newTitle.count < 2
                ? "할일은 2글자 이상 입력해주세요."
                : "하루 최대 20개까지 추가할 수 있습니다."
            showError = true
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: selectedDate)
    }
}
