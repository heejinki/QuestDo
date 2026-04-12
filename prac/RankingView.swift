//
//  RankingView.swift
//  prac
//
//  랭킹 + 칭호(해시태그) 시스템
//

import SwiftUI

struct RankingView: View {
    var rewardManager: RewardManager

    @State private var selectedTab: RankingTab = .ranking
    @State private var titleStats = TitleStats.load()

    private var profile: UserProfile { rewardManager.profile }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 탭 선택
                tabPicker
                // 컨텐츠
                switch selectedTab {
                case .ranking:
                    rankingContent
                case .titles:
                    titlesContent
                }
            }
            .background(AppBackground())
            .navigationTitle("랭킹")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    enum RankingTab: String, CaseIterable {
        case ranking = "랭킹"
        case titles = "칭호"
    }

    // MARK: - 탭 피커

    private var tabPicker: some View {
        HStack(spacing: 8) {
            ForEach(RankingTab.allCases, id: \.rawValue) { tab in
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

    // MARK: - 랭킹 목록

    private var rankingContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                myRankCard
                serverNotice
                rankingList
            }
            .padding()
        }
    }

    private var myRankCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Text("Lv.\(profile.level)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.isProfileSet ? profile.nickname : "나")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(profile.totalXP) XP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("- 위")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.tertiary)
            }

            // 획득한 칭호 해시태그 표시
            let unlocked = unlockedTitles
            if !unlocked.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(unlocked) { title in
                            Text(title.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue.opacity(0.15), .purple.opacity(0.15)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private var serverNotice: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(.blue)
            Text("랭킹은 서버 연동 후 활성화됩니다. 현재는 미리보기입니다.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .glassCard(cornerRadius: 10)
    }

    /// 목업 랭킹 데이터
    private var mockRanking: [(name: String, level: Int, xp: Int, titles: [String])] {
        [
            ("김지수", 12, 1180, ["#할일마스터", "#꾸준함의힘"]),
            ("이하은", 10, 950, ["#실행가", "#검수원"]),
            ("박민준", 8, 780, ["#도전자", "#떠오르는별"]),
            ("최서연", 7, 650, ["#목표달성자"]),
            ("정도윤", 5, 480, ["#첫발을내딛다"]),
        ]
    }

    private var rankingList: some View {
        VStack(spacing: 8) {
            ForEach(Array(mockRanking.enumerated()), id: \.offset) { index, user in
                rankRow(rank: index + 1, name: user.name, level: user.level, xp: user.xp, titles: user.titles)
            }
        }
    }

    private func rankRow(rank: Int, name: String, level: Int, xp: Int, titles: [String]) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // 순위 뱃지
                ZStack {
                    Circle()
                        .fill(rankColor(rank).opacity(0.15))
                        .frame(width: 32, height: 32)
                    Text("\(rank)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(rankColor(rank))
                }

                // 유저 아바타
                Circle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.caption)
                            .fontWeight(.medium)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Lv.\(level)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(xp) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            // 칭호 해시태그
            if !titles.isEmpty {
                HStack(spacing: 4) {
                    ForEach(titles, id: \.self) { title in
                        Text(title)
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.blue.opacity(0.08)))
                            .foregroundStyle(.blue.opacity(0.8))
                    }
                    Spacer()
                }
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 12)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: .yellow
        case 2: .gray
        case 3: .orange
        default: .secondary
        }
    }

    // MARK: - 칭호 목록

    private var titlesContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 획득한 칭호 수
                HStack {
                    Text("획득한 칭호")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(unlockedTitles.count) / \(TitleCatalog.all.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 4)

                // 카테고리별 표시
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
            Text(category.rawValue)
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(titles) { title in
                let isUnlocked = title.condition(profile, titleStats)
                titleCard(title, isUnlocked: isUnlocked)
            }
        }
    }

    private func titleCard(_ title: AchievementTitle, isUnlocked: Bool) -> some View {
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
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 12, opacity: isUnlocked ? 1.0 : 0.5)
    }

    // MARK: - 해금된 칭호

    private var unlockedTitles: [AchievementTitle] {
        TitleCatalog.all.filter { $0.condition(profile, titleStats) }
    }
}
