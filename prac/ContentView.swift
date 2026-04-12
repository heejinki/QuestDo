//
//  ContentView.swift
//  prac
//
//  앱 루트: 스플래시 → 로그인 → 메인 탭
//

import SwiftUI

struct ContentView: View {
    @State private var todoStore = TodoStore()
    @State private var rewardManager = RewardManager()
    @State private var authManager = AuthManager()
    @State private var selectedDate: Date = Date()

    // 스플래시 상태
    @State private var showSplash: Bool

    /// Preview에서 로그인 과정 건너뛰기용
    private let skipAuth: Bool

    init(skipAuth: Bool = false) {
        self.skipAuth = skipAuth
        _showSplash = State(initialValue: !skipAuth)
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if !authManager.isLoggedIn && !skipAuth {
                LoginView(authManager: authManager)
                    .transition(.opacity)
            } else {
                mainTabView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
        .onAppear {
            if !skipAuth {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showSplash = false
                }
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

            ReviewView(todoStore: todoStore, rewardManager: rewardManager)
                .tabItem {
                    Label("검수", systemImage: "checkmark.seal")
                }

            ShopView(rewardManager: rewardManager)
                .tabItem {
                    Label("상점", systemImage: "bag.fill")
                }

            RankingView(rewardManager: rewardManager)
                .tabItem {
                    Label("랭킹", systemImage: "chart.bar.fill")
                }
        }
        // 뱃지 해금 알림
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
            .toolbar {
                // 관리자 버튼
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        AdminView(
                            authManager: authManager,
                            todoStore: todoStore,
                            rewardManager: rewardManager
                        )
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.subheadline)
                    }
                }

                // 로그아웃 버튼
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        authManager.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.subheadline)
                    }
                }
            }
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

// 전체 앱 흐름 (스플래시 → 로그인 → 메인)
#Preview("앱 전체") {
    ContentView()
}

// 로그인 없이 메인 화면만 바로 확인
#Preview("메인 화면") {
    ContentView(skipAuth: true)
}
