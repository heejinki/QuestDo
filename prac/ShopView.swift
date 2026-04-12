//
//  ShopView.swift
//  prac
//
//  경험치 상점 (XP로 리워드 교환)
//

import SwiftUI

// MARK: - 상점 아이템 정의

struct ShopItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let cost: Int           // 필요 XP
    let category: ShopCategory
}

enum ShopCategory: String, CaseIterable, Identifiable {
    case gifticon = "기프티콘"
    case theme = "테마"
    case badge = "특별 뱃지"

    var id: String { rawValue }
}

// MARK: - 상점 목록 (추후 서버 연동)

enum ShopCatalog {
    static let all: [ShopItem] = [
        // 기프티콘
        ShopItem(
            id: "coffee_1", name: "아메리카노",
            description: "편의점 커피 교환권",
            icon: "cup.and.saucer.fill", cost: 500,
            category: .gifticon
        ),
        ShopItem(
            id: "coffee_2", name: "카페라떼",
            description: "카페 라떼 교환권",
            icon: "mug.fill", cost: 800,
            category: .gifticon
        ),
        ShopItem(
            id: "laptop_1", name: "맥북프로(M5)",
            description: "맥북 교환권",
            icon: "mug.fill", cost: 2000000,
            category: .gifticon
        ),
        ShopItem(
            id: "icecream_1", name: "아이스크림",
            description: "편의점 아이스크림 교환권",
            icon: "snowflake", cost: 300,
            category: .gifticon
        ),
        // 테마
        ShopItem(
            id: "theme_dark", name: "다크 테마",
            description: "어두운 분위기의 앱 테마",
            icon: "moon.fill", cost: 200,
            category: .theme
        ),
        ShopItem(
            id: "theme_ocean", name: "오션 테마",
            description: "시원한 바다 컬러 테마",
            icon: "water.waves", cost: 200,
            category: .theme
        ),
        // 특별 뱃지
        ShopItem(
            id: "badge_vip", name: "VIP 뱃지",
            description: "프로필에 VIP 마크 표시",
            icon: "star.circle.fill", cost: 1000,
            category: .badge
        ),
    ]
}

// MARK: - 상점 뷰

struct ShopView: View {
    var rewardManager: RewardManager

    @State private var selectedCategory: ShopCategory = .gifticon
    @State private var showPurchaseAlert = false
    @State private var showFailAlert = false
    @State private var targetItem: ShopItem? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 보유 XP
                xpHeader
                // 카테고리 탭
                categoryPicker
                // 상품 목록
                itemList
            }
            .background(AppBackground())
            .navigationTitle("상점")
            .navigationBarTitleDisplayMode(.inline)
            // 구매 확인 알림
            .alert("구매 확인", isPresented: $showPurchaseAlert) {
                Button("취소", role: .cancel) {}
                Button("구매") { confirmPurchase() }
            } message: {
                if let item = targetItem {
                    Text("\"\(item.name)\"을(를) \(item.cost) XP로 구매하시겠습니까?")
                }
            }
            // 잔액 부족 알림
            .alert("XP 부족", isPresented: $showFailAlert) {
                Button("확인") {}
            } message: {
                Text("보유 XP가 부족합니다. 할일을 완료하여 XP를 모아보세요!")
            }
        }
    }

    // MARK: - 보유 XP 헤더

    private var xpHeader: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("보유 XP")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(rewardManager.profile.totalXP) XP")
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal)
    }

    // MARK: - 카테고리 피커

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            ForEach(ShopCategory.allCases) { category in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedCategory == category ? .semibold : .regular)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedCategory == category ? Color.blue.opacity(0.2) : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedCategory == category ? Color.blue : Color.gray.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - 상품 목록

    private var itemList: some View {
        let filtered = ShopCatalog.all.filter { $0.category == selectedCategory }

        return ScrollView {
            VStack(spacing: 10) {
                if filtered.isEmpty {
                    Text("준비 중입니다")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 40)
                } else {
                    ForEach(filtered) { item in
                        shopItemRow(item)
                    }
                }

                // 안내 문구
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                    Text("상점은 서버 연동 후 실제 교환이 가능합니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .glassCard(cornerRadius: 10)
                .padding(.top, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    private func shopItemRow(_ item: ShopItem) -> some View {
        let canAfford = rewardManager.profile.totalXP >= item.cost

        return HStack(spacing: 14) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: item.icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
            }

            // 상품 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 가격 + 구매 버튼
            Button {
                targetItem = item
                if canAfford {
                    showPurchaseAlert = true
                } else {
                    showFailAlert = true
                }
            } label: {
                Text("\(item.cost) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(canAfford ? Color.blue : Color.gray.opacity(0.3))
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .glassCard(cornerRadius: 12)
    }

    // MARK: - 구매 확정

    private func confirmPurchase() {
        guard let item = targetItem else { return }
        let success = rewardManager.spendXP(item.cost)
        if !success {
            showFailAlert = true
        }
        // 실제 교환 로직은 서버 연동 후 구현
        targetItem = nil
    }
}
