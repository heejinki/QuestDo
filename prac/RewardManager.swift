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

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = UserProfile()
        }
    }

    // MARK: XP 추가

    func addXP(_ amount: Int) -> Int {
        // 완료 취소 시 음수 처리
        if amount < 0 {
            profile.totalXP = max(0, profile.totalXP + amount)
            profile.completedCount = max(0, profile.completedCount - 1)
            save()
            return amount
        }

        profile.totalXP += amount
        profile.completedCount += 1

        updateStreak()
        checkBadges()
        save()

        return amount
    }

    // MARK: 연속 달성

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastActive = profile.lastActiveDate {
            let lastDay = calendar.startOfDay(for: lastActive)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if diff == 1 {
                profile.currentStreak += 1
            } else if diff > 1 {
                profile.currentStreak = 1
            }
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

    // MARK: 저장

    private func save() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
    }
}
