//
//  ContentView.swift
//  prac
//
//  앱 루트: 스플래시 → 메인 탭
//

import SwiftUI

struct ContentView: View {
    @State private var todoStore = TodoStore()
    @State private var rewardManager = RewardManager()
    @State private var selectedDate: Date = Date()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                mainTabView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSplash = false
            }
        }
    }

    // MARK: - 메인 탭

    private var mainTabView: some View {
        TabView {
            homeTab
                .tabItem {
                    Label("캘린더", systemImage: "calendar")
                }

            RewardView(rewardManager: rewardManager)
                .tabItem {
                    Label("성과", systemImage: "trophy")
                }

            AchievementView(rewardManager: rewardManager)
                .tabItem {
                    Label("업적", systemImage: "medal")
                }
        }
        .alert("뱃지 획득!", isPresented: badgeAlertBinding) {
            Button("확인") { rewardManager.dismissBadgeAlert() }
        } message: {
            if let badge = rewardManager.newlyUnlockedBadge {
                Text("\"\(badge.name)\" 뱃지를 획득했습니다!\n\(badge.description)")
            }
        }
    }

    // MARK: - 홈 탭 (캘린더 + 할일)

    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CalendarView(
                        selectedDate: $selectedDate,
                        todoStore: todoStore
                    )

                    TodoListView(
                        selectedDate: selectedDate,
                        todoStore: todoStore,
                        rewardManager: rewardManager
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(AppBackground())
            .navigationTitle("오늘의 할일")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - 뱃지 알림 바인딩

    private var badgeAlertBinding: Binding<Bool> {
        Binding(
            get: { rewardManager.newlyUnlockedBadge != nil },
            set: { if !$0 { rewardManager.dismissBadgeAlert() } }
        )
    }
}

#Preview {
    ContentView()
}
