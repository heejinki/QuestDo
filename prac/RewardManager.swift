//
//  RewardManager.swift
//  prac
//
//  경험치, 레벨, 뱃지, 연속달성 관리
//

import SwiftUI

// MARK: - 리워드 관리자

@Observable
class RewardManager {
    var profile: UserProfile
    /// 방금 해금된 뱃지 (알림 표시용)
    var newlyUnlockedBadge: Badge? = nil

    private let saveKey = "user_profile"

    /// 일일 XP 상한 (어뷰징 방지)
    private let dailyXPCap = 500

    /// 오늘 획득한 XP (앱 실행 중 추적)
    private(set) var todayXP: Int = 0

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = UserProfile()
        }
    }

    // MARK: XP 추가

    /// XP 부여. 일일 상한 초과 시 0 반환
    func addXP(_ amount: Int) -> Int {
        // 음수(완료 취소)는 상한 적용 없이 처리
        if amount < 0 {
            profile.totalXP = max(0, profile.totalXP + amount)
            profile.completedCount = max(0, profile.completedCount - 1)
            save()
            return amount
        }

        // 일일 상한 확인
        guard todayXP + amount <= dailyXPCap else { return 0 }

        let previousLevel = profile.level
        profile.totalXP += amount
        profile.completedCount += 1
        todayXP += amount

        // 연속 달성 업데이트
        updateStreak()
        // 뱃지 확인
        checkBadges()

        save()

        // 레벨업 여부 반환 (UI 연출용)
        let gained = profile.level > previousLevel ? amount : amount
        return gained
    }

    // MARK: 연속 달성

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastActive = profile.lastActiveDate {
            let lastDay = calendar.startOfDay(for: lastActive)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if diff == 1 {
                // 어제 활동 → 연속 +1
                profile.currentStreak += 1
            } else if diff > 1 {
                // 하루 이상 빠짐 → 리셋
                profile.currentStreak = 1
            }
            // diff == 0 → 오늘 이미 갱신됨, 유지
        } else {
            profile.currentStreak = 1
        }

        profile.lastActiveDate = Date()
    }

    // MARK: 뱃지 해금 확인

    private func checkBadges() {
        for badge in BadgeCatalog.all {
            if !profile.unlockedBadgeIDs.contains(badge.id),
               badge.condition(profile) {
                profile.unlockedBadgeIDs.insert(badge.id)
                newlyUnlockedBadge = badge
            }
        }
    }

    /// 뱃지 해금 알림 닫기
    func dismissBadgeAlert() {
        newlyUnlockedBadge = nil
    }

    // MARK: 프로필 업데이트

    func updateProfile(nickname: String, age: Int?, gender: Gender?, imageData: Data?) {
        profile.nickname = nickname
        profile.age = age
        profile.gender = gender
        profile.profileImageData = imageData
        save()
    }

    // MARK: XP 차감 (상점 구매용)

    /// XP 차감. 잔액 부족 시 false 반환
    func spendXP(_ amount: Int) -> Bool {
        guard profile.totalXP >= amount else { return false }
        profile.totalXP -= amount
        save()
        return true
    }

    // MARK: 남은 일일 XP

    var remainingDailyXP: Int {
        max(0, dailyXPCap - todayXP)
    }

    // MARK: 저장

    private func save() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
    }
}
