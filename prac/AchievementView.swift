//
//  AchievementView.swift
//  prac
//
//  업적(뱃지) + 칭호 화면 + SNS 공유
//

import SwiftUI

// MARK: - 업적 탭 뷰

struct AchievementView: View {
    var rewardManager: RewardManager

    @State private var selectedTab: AchievementTab = .badges
    @State private var selectedCategory: BadgeCategory = .completion

    private var profile: UserProfile { rewardManager.profile }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabPicker
                switch selectedTab {
                case .badges:  badgesContent
                case .titles:  titlesContent
                }
            }
            .background(AppBackground())
            .navigationTitle("업적")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    enum AchievementTab: String, CaseIterable {
        case badges = "뱃지"
        case titles = "칭호"
    }

    // MARK: - 탭 피커

    private var tabPicker: some View {
        HStack(spacing: 8) {
            ForEach(AchievementTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(selectedTab == tab ? Color.blue.opacity(0.2) : Color.clear))
                        .overlay(Capsule().stroke(selectedTab == tab ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }

    // MARK: - 뱃지 화면

    private var badgesContent: some View {
        let unlockedCount = profile.unlockedBadgeIDs.count
        let totalCount = BadgeCatalog.all.count

        return ScrollView {
            VStack(spacing: 16) {
                // 진행 요약
                progressSummary(unlocked: unlockedCount, total: totalCount)

                // 카테고리 필터
                categoryFilter

                // 뱃지 그리드
                let filtered = BadgeCatalog.all.filter { $0.category == selectedCategory }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(filtered) { badge in
                        let isUnlocked = profile.unlockedBadgeIDs.contains(badge.id)
                        badgeCard(badge, isUnlocked: isUnlocked)
                    }
                }
            }
            .padding()
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BadgeCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = category }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.caption2)
                            Text(category.rawValue)
                                .font(.caption)
                        }
                        .fontWeight(selectedCategory == category ? .semibold : .regular)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear))
                        .overlay(Capsule().stroke(selectedCategory == category ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func badgeCard(_ badge: Badge, isUnlocked: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: badge.icon)
                .font(.title2)
                .foregroundStyle(isUnlocked ? .yellow : .gray.opacity(0.3))

            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            Text(badge.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // 공유 버튼 (해금된 경우만)
            if isUnlocked {
                ShareButton(icon: badge.icon, name: badge.name, description: badge.description, nickname: profile.nickname)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .glassCard(cornerRadius: 12, opacity: isUnlocked ? 1.0 : 0.4)
    }

    // MARK: - 칭호 화면

    private var titlesContent: some View {
        let unlocked = TitleCatalog.all.filter { $0.condition(profile) }
        let totalCount = TitleCatalog.all.count

        return ScrollView {
            VStack(spacing: 16) {
                progressSummary(unlocked: unlocked.count, total: totalCount)

                ForEach(TitleCategory.allCases) { category in
                    titleCategorySection(category)
                }
            }
            .padding()
        }
    }

    private func titleCategorySection(_ category: TitleCategory) -> some View {
        let titles = TitleCatalog.all.filter { $0.category == category }
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .foregroundStyle(.blue)
                Text(category.rawValue)
                    .font(.headline)
            }
            .padding(.horizontal, 4)

            ForEach(titles) { title in
                let isUnlocked = title.condition(profile)
                titleRow(title, isUnlocked: isUnlocked)
            }
        }
    }

    private func titleRow(_ title: AchievementTitle, isUnlocked: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: title.icon)
                .font(.title3)
                .foregroundStyle(isUnlocked ? .yellow : .gray.opacity(0.3))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(title.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)
                Text(title.description)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if isUnlocked {
                ShareButton(icon: title.icon, name: title.name, description: title.description, nickname: profile.nickname)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 12, opacity: isUnlocked ? 1.0 : 0.4)
    }

    // MARK: - 진행 요약

    private func progressSummary(unlocked: Int, total: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("획득 현황")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(unlocked) / \(total)")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            Spacer()
            // 진행률 원형 표시
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: total > 0 ? Double(unlocked) / Double(total) : 0)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(total > 0 ? unlocked * 100 / total : 0)%")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .frame(width: 50, height: 50)
        }
        .padding(16)
        .glassCard()
    }
}

// MARK: - 공유 버튼

struct ShareButton: View {
    let icon: String
    let name: String
    let description: String
    let nickname: String

    var body: some View {
        Button {
            shareAchievement()
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 10))
                Text("공유")
                    .font(.caption2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.blue.opacity(0.15)))
            .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func shareAchievement() {
        let card = AchievementShareCard(icon: icon, name: name, description: description, nickname: nickname)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3.0

        guard let uiImage = renderer.uiImage else { return }

        let activityVC = UIActivityViewController(
            activityItems: [uiImage],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }

        // iPad 팝오버 지원
        activityVC.popoverPresentationController?.sourceView = window
        activityVC.popoverPresentationController?.sourceRect = CGRect(
            x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0
        )
        activityVC.popoverPresentationController?.permittedArrowDirections = []

        rootVC.present(activityVC, animated: true)
    }
}

// MARK: - 공유용 이미지 카드

struct AchievementShareCard: View {
    let icon: String
    let name: String
    let description: String
    let nickname: String

    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.2, blue: 0.6), Color(red: 0.4, green: 0.1, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 배경 장식 원
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 300, height: 300)
                .offset(x: 120, y: -120)

            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: 130)

            VStack(spacing: 20) {
                // 앱 이름
                Text("QuestDo")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                // 아이콘
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 100, height: 100)
                    Image(systemName: icon)
                        .font(.system(size: 44))
                        .foregroundStyle(.yellow)
                }

                // 업적 이름
                Text(name)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                // 설명
                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                // 구분선
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 60, height: 1)

                // 닉네임
                if !nickname.isEmpty {
                    Text(nickname)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(40)
        }
        .frame(width: 380, height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
