//
//  ReviewView.swift
//  prac
//
//  다른 유저의 할일을 검수하는 화면
//  (현재 로컬 목업 + 자체 검수 / 추후 서버 연동 시 피어 검수)
//

import SwiftUI

// MARK: - 검수 탭 뷰

struct ReviewView: View {
    var todoStore: TodoStore
    var rewardManager: RewardManager

    @State private var selectedTab: ReviewTab = .peerReview

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 탭 선택
                reviewTabPicker

                // 컨텐츠
                switch selectedTab {
                case .peerReview:
                    peerReviewList
                case .myStatus:
                    myReviewStatusList
                }
            }
            .background(AppBackground())
            .navigationTitle("검수")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - 탭 종류

    enum ReviewTab: String, CaseIterable {
        case peerReview = "검수하기"
        case myStatus = "내 검수 현황"
    }

    // MARK: - 탭 피커

    private var reviewTabPicker: some View {
        HStack(spacing: 8) {
            ForEach(ReviewTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedTab == tab ? Color.blue : Color.gray.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }

    // MARK: - 피어 검수 목록

    private var peerReviewList: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 검수 XP 안내
                reviewInfoBanner

                // 검수 대기 항목 (로컬: 자신의 항목 / 서버 연동 시: 타인의 항목)
                let pending = todoStore.pendingReviewItems
                if pending.isEmpty {
                    emptyReviewState
                } else {
                    ForEach(pending) { item in
                        PeerReviewCard(
                            item: item,
                            onApprove: { comment in approveItem(item, comment: comment) },
                            onReject: { comment in rejectItem(item, comment: comment) }
                        )
                    }
                }

                // 목업: 다른 유저의 검수 요청 (서버 연동 미리보기)
                mockPeerSection
            }
            .padding()
        }
    }

    // MARK: - 내 검수 현황

    private var myReviewStatusList: some View {
        let reviewed = todoStore.items.filter {
            $0.isDone && $0.reviewStatus != .none && $0.reviewStatus != .autoApproved
        }

        return ScrollView {
            VStack(spacing: 10) {
                if reviewed.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                        Text("검수 내역이 없습니다")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("보통/어려움 난이도의 할일을 완료하면\n검수 대기 목록에 등록됩니다")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 60)
                } else {
                    ForEach(reviewed) { item in
                        myStatusRow(item)
                    }
                }
            }
            .padding()
        }
    }

    private func myStatusRow(_ item: TodoItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.reviewStatus.icon)
                .font(.title3)
                .foregroundStyle(statusColor(item.reviewStatus))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)

                HStack(spacing: 4) {
                    Text(item.reviewStatus.label)
                        .font(.caption)
                        .foregroundStyle(statusColor(item.reviewStatus))
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text("\(item.difficulty.label) · \(item.difficulty.xp)XP")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

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
        }
        .padding(12)
        .glassCard(cornerRadius: 12)
    }

    // MARK: - 검수 처리

    private func approveItem(_ item: TodoItem, comment: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            // 할일 작성자에게 XP 지급
            let authorXP = todoStore.approveReview(item.id, comment: comment)
            if authorXP > 0 {
                _ = rewardManager.addXP(authorXP)
            }
            // 검수자에게 검수 XP 지급
            let reviewXP = item.difficulty.reviewXP
            if reviewXP > 0 {
                _ = rewardManager.addXP(reviewXP)
            }
        }
    }

    private func rejectItem(_ item: TodoItem, comment: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            todoStore.rejectReview(item.id, comment: comment)
            // 검수자에게 검수 XP 지급 (거절도 검수 활동)
            let reviewXP = item.difficulty.reviewXP
            if reviewXP > 0 {
                _ = rewardManager.addXP(reviewXP)
            }
        }
    }

    // MARK: - 안내 배너

    private var reviewInfoBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "gift.fill")
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("검수하면 XP를 받을 수 있어요!")
                    .font(.caption)
                    .fontWeight(.medium)
                Text("보통 검수: 5XP · 어려움 검수: 10XP")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .glassCard(cornerRadius: 10)
    }

    // MARK: - 빈 상태

    private var emptyReviewState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("검수할 항목이 없습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 40)
    }

    // MARK: - 목업 피어 검수 (서버 연동 미리보기)

    private var mockPeerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.blue)
                Text("다른 유저의 검수 요청")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.top, 8)

            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                Text("서버 연동 후 다른 유저의 할일을 검수할 수 있습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .glassCard(cornerRadius: 10)

            // 목업 카드
            ForEach(mockPeerItems) { mock in
                mockPeerCard(mock)
            }
        }
    }

    private var mockPeerItems: [MockPeerTodo] {
        [
            MockPeerTodo(user: "김지수", title: "알고리즘 문제 3개 풀기", difficulty: .hard, note: "백준 골드 문제 3개 완료"),
            MockPeerTodo(user: "이하은", title: "영어 단어 50개 암기", difficulty: .medium, note: "Quizlet으로 학습 완료"),
        ]
    }

    private func mockPeerCard(_ mock: MockPeerTodo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(String(mock.user.prefix(1)))
                            .font(.caption2)
                            .fontWeight(.medium)
                    )
                Text(mock.user)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text("\(mock.difficulty.label) · \(mock.difficulty.reviewXP)XP")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(mock.title)
                .font(.subheadline)

            Text("📝 \(mock.note)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text("서버 연동 후 검수 가능")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 12, opacity: 0.5)
    }

    private func statusColor(_ status: ReviewStatus) -> Color {
        switch status {
        case .pendingReview: .orange
        case .approved: .green
        case .rejected: .red
        default: .gray
        }
    }
}

// MARK: - 목업 데이터 구조

struct MockPeerTodo: Identifiable {
    let id = UUID()
    let user: String
    let title: String
    let difficulty: Difficulty
    let note: String
}

// MARK: - 개별 검수 카드 (실제 검수용)

struct PeerReviewCard: View {
    let item: TodoItem
    var onApprove: (String) -> Void
    var onReject: (String) -> Void

    @State private var isExpanded = false
    @State private var comment = ""
    @State private var showRejectAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 헤더
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.orange)
                Text("검수 대기")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
                Spacer()
                Text("\(item.difficulty.label) · \(item.difficulty.xp)XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 할일 제목
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.medium)

            // 완료 메모
            if !item.completionNote.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(item.completionNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }

            // 날짜 정보
            HStack(spacing: 8) {
                Text("등록: \(formatDate(item.createdAt))")
                if let completed = item.completedAt {
                    Text("완료: \(formatDate(completed))")
                }
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)

            // 검수 코멘트 입력
            if isExpanded {
                TextField("코멘트 (선택사항)", text: $comment)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
            }

            // 검수 버튼
            HStack(spacing: 10) {
                if isExpanded {
                    // 승인
                    Button {
                        onApprove(comment)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                            Text("승인")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.green.opacity(0.15)))
                        .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)

                    // 거절
                    Button {
                        if comment.trimmingCharacters(in: .whitespaces).isEmpty {
                            showRejectAlert = true
                        } else {
                            onReject(comment)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("거절")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.red.opacity(0.15)))
                        .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded = true
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "magnifyingglass")
                            Text("검수하기")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.blue.opacity(0.15)))
                        .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 12)
        .alert("거절 사유 필요", isPresented: $showRejectAlert) {
            Button("확인") {}
        } message: {
            Text("거절 시 코멘트를 입력해주세요.")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: date)
    }
}
