//
//  AdminView.swift
//  prac
//
//  관리자 페이지 (모든 데이터 관리 권한)
//

import SwiftUI

struct AdminView: View {
    var authManager: AuthManager
    var todoStore: TodoStore
    var rewardManager: RewardManager

    @State private var passwordInput = ""
    @State private var showWrongPassword = false

    var body: some View {
        NavigationStack {
            if authManager.isAdmin {
                adminDashboard
            } else {
                passwordEntry
            }
        }
    }

    // MARK: - 비밀번호 입력

    private var passwordEntry: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("관리자 인증")
                .font(.title2)
                .fontWeight(.bold)

            Text("관리자 비밀번호를 입력하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            SecureField("비밀번호", text: $passwordInput)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)
                .multilineTextAlignment(.center)
                .onSubmit { verifyPassword() }

            Button {
                verifyPassword()
            } label: {
                Text("확인")
                    .fontWeight(.semibold)
                    .frame(width: 120)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            if showWrongPassword {
                Text("비밀번호가 틀립니다")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()
        }
        .background(AppBackground())
    }

    private func verifyPassword() {
        if authManager.verifyAdmin(password: passwordInput) {
            showWrongPassword = false
        } else {
            showWrongPassword = true
            passwordInput = ""
        }
    }

    // MARK: - 관리자 대시보드

    private var adminDashboard: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 통계 요약
                statsOverview
                // 전체 할일 관리
                allTodosSection
                // 검수 대기 관리
                pendingReviewSection
                // 유저 데이터 관리
                dataManagementSection
                // 관리자 나가기
                exitButton
            }
            .padding()
        }
        .background(AppBackground())
        .navigationTitle("관리자")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 통계 요약

    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("대시보드")
                .font(.headline)

            HStack(spacing: 12) {
                adminStat(title: "전체 할일", value: "\(todoStore.items.count)", icon: "list.bullet", color: .blue)
                adminStat(title: "검수 대기", value: "\(todoStore.pendingReviewItems.count)", icon: "clock", color: .orange)
            }
            HStack(spacing: 12) {
                adminStat(title: "총 XP", value: "\(rewardManager.profile.totalXP)", icon: "star.fill", color: .yellow)
                adminStat(title: "레벨", value: "Lv.\(rewardManager.profile.level)", icon: "arrow.up", color: .green)
            }
        }
    }

    private func adminStat(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .padding(12)
        .glassCard(cornerRadius: 10)
    }

    // MARK: - 전체 할일 목록

    private var allTodosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("전체 할일 (\(todoStore.items.count))")
                .font(.headline)

            if todoStore.items.isEmpty {
                Text("등록된 할일이 없습니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(todoStore.items.prefix(20)) { item in
                    adminTodoRow(item)
                }
                if todoStore.items.count > 20 {
                    Text("외 \(todoStore.items.count - 20)건...")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.leading, 4)
                }
            }
        }
    }

    private func adminTodoRow(_ item: TodoItem) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(item.isDone ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .font(.caption)
                    .strikethrough(item.isDone)
                HStack(spacing: 4) {
                    Text(item.difficulty.label)
                    Text("·")
                    Text(item.reviewStatus.label)
                    Text("·")
                    Text(formatDate(item.date))
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            // 강제 삭제
            Button {
                withAnimation { todoStore.delete(item.id) }
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .glassCard(cornerRadius: 8)
    }

    // MARK: - 검수 대기 관리

    private var pendingReviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("검수 대기 (\(todoStore.pendingReviewItems.count))")
                .font(.headline)

            if todoStore.pendingReviewItems.isEmpty {
                Text("검수 대기 항목 없음")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(todoStore.pendingReviewItems) { item in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.caption)
                            if !item.completionNote.isEmpty {
                                Text("📝 \(item.completionNote)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        // 관리자 강제 승인
                        Button {
                            withAnimation {
                                let xp = todoStore.approveReview(item.id, comment: "관리자 승인")
                                if xp > 0 { _ = rewardManager.addXP(xp) }
                            }
                        } label: {
                            Text("승인")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(.green.opacity(0.15)))
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)

                        // 관리자 강제 거절
                        Button {
                            withAnimation {
                                todoStore.rejectReview(item.id, comment: "관리자 거절")
                            }
                        } label: {
                            Text("거절")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(.red.opacity(0.15)))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .glassCard(cornerRadius: 8)
                }
            }
        }
    }

    // MARK: - 데이터 관리

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("데이터 관리")
                .font(.headline)

            // XP 수동 조정
            HStack {
                Text("XP 수동 추가")
                    .font(.caption)
                Spacer()
                Button {
                    _ = rewardManager.addXP(100)
                } label: {
                    Text("+100 XP")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(.blue.opacity(0.15)))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            .glassCard(cornerRadius: 8)

            // 전체 데이터 초기화
            Button {
                // 주의: 모든 할일 삭제
                withAnimation {
                    todoStore.items.removeAll()
                    UserDefaults.standard.removeObject(forKey: "todo_items")
                }
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("전체 할일 초기화")
                }
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.red.opacity(0.1))
                )
                .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 관리자 나가기

    private var exitButton: some View {
        Button {
            authManager.exitAdmin()
        } label: {
            HStack {
                Image(systemName: "arrow.left.circle")
                Text("관리자 모드 나가기")
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: 12)
        }
        .buttonStyle(.plain)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
