//
//  RewardView.swift
//  prac
//
//  프로필, 레벨, XP, 뱃지 표시
//

import SwiftUI
import PhotosUI

struct RewardView: View {
    var rewardManager: RewardManager

    @State private var showProfileEdit = false

    private var profile: UserProfile { rewardManager.profile }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 프로필 카드
                    profileCard
                    // 레벨 카드
                    levelCard
                    // 통계
                    statsCard
                    // 뱃지 목록
                    badgeSection
                }
                .padding()
            }
            .background(AppBackground())
            .navigationTitle("내 성과")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showProfileEdit) {
                ProfileEditSheet(rewardManager: rewardManager)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - 프로필 카드

    private var profileCard: some View {
        HStack(spacing: 16) {
            // 프로필 사진
            profileImage
                .frame(width: 60, height: 60)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                if profile.isProfileSet {
                    Text(profile.nickname)
                        .font(.title3)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        if let gender = profile.gender {
                            Text(gender.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let age = profile.age {
                            Text("\(age)세")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text("프로필을 설정해주세요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                showProfileEdit = true
            } label: {
                Image(systemName: "pencil.circle")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
        .padding(16)
        .glassCard()
    }

    @ViewBuilder
    private var profileImage: some View {
        if let data = profile.profileImageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Circle()
                    .fill(.gray.opacity(0.2))
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
        }
    }

    // MARK: - 레벨 카드

    private var levelCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.15))
                    .frame(width: 80, height: 80)
                Text("Lv.\(profile.level)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 6) {
                HStack {
                    Text("경험치")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(profile.currentLevelXP) / \(profile.xpForNextLevel) XP")
                        .font(.caption)
                        .fontWeight(.medium)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * profile.levelProgress,
                                height: 8
                            )
                            .animation(.easeOut(duration: 0.5), value: profile.levelProgress)
                    }
                }
                .frame(height: 8)
            }

        }
        .padding(20)
        .glassCard()
    }

    // MARK: - 통계 카드

    private var statsCard: some View {
        HStack(spacing: 12) {
            statItem(icon: "checkmark.circle", value: "\(profile.completedCount)", label: "완료")
            statItem(icon: "flame", value: "\(profile.currentStreak)일", label: "연속")
            statItem(icon: "star.fill", value: "\(profile.totalXP)", label: "총 XP")
            statItem(
                icon: "medal",
                value: "\(profile.unlockedBadgeIDs.count)/\(BadgeCatalog.all.count)",
                label: "뱃지"
            )
        }
        .padding(16)
        .glassCard()
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 뱃지 섹션

    private var badgeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("뱃지")
                .font(.headline)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(BadgeCatalog.all) { badge in
                    badgeCard(badge)
                }
            }
        }
    }

    private func badgeCard(_ badge: Badge) -> some View {
        let isUnlocked = profile.unlockedBadgeIDs.contains(badge.id)

        return VStack(spacing: 8) {
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
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .glassCard(cornerRadius: 12, opacity: isUnlocked ? 1.0 : 0.5)
    }
}

// MARK: - 프로필 편집 시트

struct ProfileEditSheet: View {
    var rewardManager: RewardManager
    @Environment(\.dismiss) private var dismiss

    @State private var nickname: String
    @State private var ageText: String
    @State private var gender: Gender?
    @State private var imageData: Data?
    @State private var selectedPhoto: PhotosPickerItem? = nil

    init(rewardManager: RewardManager) {
        self.rewardManager = rewardManager
        let p = rewardManager.profile
        _nickname = State(initialValue: p.nickname)
        _ageText = State(initialValue: p.age.map { String($0) } ?? "")
        _gender = State(initialValue: p.gender)
        _imageData = State(initialValue: p.profileImageData)
    }

    var body: some View {
        NavigationStack {
            Form {
                // 프로필 사진
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            profileImagePreview
                        }
                        .onChange(of: selectedPhoto) { _, newValue in
                            loadPhoto(newValue)
                        }
                        Spacer()
                    }
                } header: {
                    Text("프로필 사진")
                } footer: {
                    Text("사진을 탭하여 변경")
                }

                // 기본 정보
                Section("기본 정보") {
                    TextField("닉네임", text: $nickname)

                    TextField("나이", text: $ageText)
                        .keyboardType(.numberPad)

                    Picker("성별", selection: $gender) {
                        Text("선택 안함").tag(nil as Gender?)
                        ForEach(Gender.allCases) { g in
                            Text(g.rawValue).tag(g as Gender?)
                        }
                    }
                }
            }
            .navigationTitle("프로필 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    @ViewBuilder
    private var profileImagePreview: some View {
        if let data = imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        item.loadTransferable(type: Data.self) { result in
            if case .success(let data) = result {
                // JPEG로 압축하여 용량 절약
                if let data,
                   let uiImage = UIImage(data: data),
                   let compressed = uiImage.jpegData(compressionQuality: 0.5) {
                    DispatchQueue.main.async {
                        imageData = compressed
                    }
                }
            }
        }
    }

    private func saveProfile() {
        let age = Int(ageText)
        rewardManager.updateProfile(
            nickname: nickname,
            age: age,
            gender: gender,
            imageData: imageData
        )
    }
}
