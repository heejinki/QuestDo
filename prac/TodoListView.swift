//
//  TodoListView.swift
//  prac
//
//  선택된 날짜의 할일 목록 표시 + 추가/삭제
//

import SwiftUI
import PhotosUI

struct TodoListView: View {
    var selectedDate: Date
    var todoStore: TodoStore
    var rewardManager: RewardManager

    @State private var newTitle: String = ""
    @State private var newDifficulty: Difficulty = .medium
    @State private var showAddForm: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    // 완료 메모 입력용
    @State private var showCompleteSheet: Bool = false
    @State private var completingItemID: UUID? = nil
    @State private var completionNote: String = ""
    @State private var completionImageData: Data? = nil

    private var todos: [TodoItem] {
        todoStore.todos(for: selectedDate)
    }

    var body: some View {
        VStack(spacing: 12) {
            dateHeader
            todoList
            addButton
        }
        // 완료 메모 시트
        .sheet(isPresented: $showCompleteSheet) {
            CompletionNoteSheet(
                note: $completionNote,
                imageData: $completionImageData,
                onSubmit: { submitCompletion() },
                onCancel: {
                    showCompleteSheet = false
                    completionImageData = nil
                }
            )
            .presentationDetents([.large])
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
                Image(systemName: statusIcon(for: item))
                    .font(.title3)
                    .foregroundStyle(statusColor(for: item))
            }
            .buttonStyle(.plain)

            // 할일 내용
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .strikethrough(item.isDone)
                    .foregroundStyle(item.isDone ? .secondary : .primary)

                // 난이도 + XP + 검수 상태
                HStack(spacing: 4) {
                    Image(systemName: item.difficulty.icon)
                        .font(.caption2)
                    Text("\(item.difficulty.label) · \(item.difficulty.xp)XP")
                        .font(.caption2)

                    // 검수 상태 뱃지
                    if item.isDone && item.needsReview {
                        Text(item.reviewStatus.label)
                            .font(.system(size: 9))
                            .fontWeight(.medium)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(
                                Capsule().fill(reviewStatusColor(item.reviewStatus).opacity(0.15))
                            )
                            .foregroundStyle(reviewStatusColor(item.reviewStatus))
                    }
                }
                .foregroundStyle(.tertiary)

                // 검수자 코멘트 표시
                if let comment = item.reviewerComment {
                    HStack(spacing: 3) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 8))
                        Text(comment)
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top, 1)
                }
            }

            Spacer()

            // 삭제 (검수 승인된 항목은 삭제 불가)
            if item.reviewStatus != .approved {
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
        }
        .padding(12)
        .glassCard(cornerRadius: 12, opacity: item.isDone ? 0.6 : 1.0)
    }

    // MARK: - 완료/취소 토글 처리

    private func handleToggle(_ item: TodoItem) {
        if item.isDone {
            // 완료 취소
            withAnimation(.easeInOut(duration: 0.3)) {
                let xp = todoStore.uncomplete(item.id)
                if xp != 0 {
                    _ = rewardManager.addXP(xp)
                }
            }
        } else {
            if item.needsReview {
                // 보통/어려움: 메모 시트 띄우기
                completingItemID = item.id
                completionNote = ""
                showCompleteSheet = true
            } else {
                // 쉬움: 바로 완료
                withAnimation(.easeInOut(duration: 0.3)) {
                    let xp = todoStore.completeWithReview(item.id, note: "")
                    if xp != 0 {
                        _ = rewardManager.addXP(xp)
                    }
                }
            }
        }
    }

    /// 완료 메모 제출
    private func submitCompletion() {
        guard let id = completingItemID else { return }
        showCompleteSheet = false

        withAnimation(.easeInOut(duration: 0.3)) {
            let xp = todoStore.completeWithReview(id, note: completionNote)
            if xp != 0 {
                _ = rewardManager.addXP(xp)
            }
        }

        completingItemID = nil
        completionNote = ""
        completionImageData = nil
    }

    // MARK: - 상태별 아이콘/색상

    private func statusIcon(for item: TodoItem) -> String {
        if !item.isDone { return "circle" }
        return item.reviewStatus.icon
    }

    private func statusColor(for item: TodoItem) -> Color {
        if !item.isDone { return .secondary }
        switch item.reviewStatus {
        case .autoApproved, .approved: return .green
        case .pendingReview: return .orange
        case .rejected: return .red
        case .none: return .secondary
        }
    }

    private func reviewStatusColor(_ status: ReviewStatus) -> Color {
        switch status {
        case .pendingReview: .orange
        case .approved: .blue
        case .rejected: .red
        default: .gray
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
        VStack(spacing: 10) {
            TextField("할일을 입력하세요 (2글자 이상)", text: $newTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit { submitTodo() }

            HStack(spacing: 8) {
                ForEach(Difficulty.allCases) { diff in
                    Button {
                        newDifficulty = diff
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: diff.icon)
                                .font(.caption2)
                            Text(diff.label)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(newDifficulty == diff ? Color.blue.opacity(0.2) : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .stroke(newDifficulty == diff ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {
                    submitTodo()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .disabled(newTitle.trimmingCharacters(in: .whitespaces).count < 2)
            }

            // 검수 안내
            if newDifficulty != .easy {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                    Text("보통/어려움은 완료 시 검수가 필요합니다")
                        .font(.caption2)
                }
                .foregroundStyle(.orange)
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 12)
        .padding(.horizontal)
    }

    private func submitTodo() {
        let success = todoStore.add(
            title: newTitle,
            date: selectedDate,
            difficulty: newDifficulty
        )

        if success {
            newTitle = ""
            newDifficulty = .medium
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

// MARK: - 완료 메모 시트

struct CompletionNoteSheet: View {
    @Binding var note: String
    @Binding var imageData: Data?
    var onSubmit: () -> Void
    var onCancel: () -> Void

    @State private var selectedPhoto: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 안내
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.blue)
                        Text("완료 내용을 간단히 기록해주세요.\n다른 유저가 검수할 때 참고합니다.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .glassCard(cornerRadius: 12)

                    // 메모 입력
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("예: 30분 운동 완료했습니다...")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }

                    // 사진 첨부
                    VStack(alignment: .leading, spacing: 8) {
                        Text("인증 사진 (선택)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let data = imageData, let uiImage = UIImage(data: data) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                Button {
                                    imageData = nil
                                    selectedPhoto = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white, .black.opacity(0.5))
                                }
                                .padding(6)
                            }
                        }

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 6) {
                                Image(systemName: "camera.fill")
                                Text(imageData == nil ? "사진 추가" : "사진 변경")
                            }
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .onChange(of: selectedPhoto) { _, newValue in
                            loadPhoto(newValue)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("완료 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { onSubmit() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        item.loadTransferable(type: Data.self) { result in
            if case .success(let data) = result,
               let data,
               let uiImage = UIImage(data: data),
               let compressed = uiImage.jpegData(compressionQuality: 0.5) {
                DispatchQueue.main.async {
                    imageData = compressed
                }
            }
        }
    }
}
