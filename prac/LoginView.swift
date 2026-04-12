//
//  LoginView.swift
//  prac
//
//  로그인 / 회원가입 화면
//

import SwiftUI

struct LoginView: View {
    var authManager: AuthManager

    @State private var isRegisterMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)

                    // 앱 로고
                    appLogo

                    // 소셜 로그인 버튼
                    socialLoginSection

                    // 구분선
                    divider

                    // 이메일 로그인/회원가입 폼
                    emailSection

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .alert("알림", isPresented: $showError) {
            Button("확인") {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - 앱 로고

    private var appLogo: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("QuestDo")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("할일을 완료하고 성장하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 소셜 로그인

    private var socialLoginSection: some View {
        VStack(spacing: 10) {
            // Apple 로그인
            socialButton(
                title: "Apple로 계속하기",
                icon: "apple.logo",
                bgColor: .black,
                fgColor: .white,
                provider: .apple
            )

            // Google 로그인
            socialButton(
                title: "Google로 계속하기",
                icon: "g.circle.fill",
                bgColor: .white,
                fgColor: .black,
                provider: .google
            )

            // 카카오 로그인
            socialButton(
                title: "카카오로 계속하기",
                icon: "message.fill",
                bgColor: Color(red: 1, green: 0.9, blue: 0),
                fgColor: .black,
                provider: .kakao
            )

            // 네이버 로그인
            socialButton(
                title: "네이버로 계속하기",
                icon: "n.circle.fill",
                bgColor: Color(red: 0.12, green: 0.78, blue: 0.35),
                fgColor: .white,
                provider: .naver
            )
        }
    }

    private func socialButton(
        title: String,
        icon: String,
        bgColor: Color,
        fgColor: Color,
        provider: AuthProvider
    ) -> some View {
        Button {
            withAnimation { authManager.loginWithSocial(provider) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundStyle(fgColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: bgColor == .white ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 구분선

    private var divider: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
            Text("또는")
                .font(.caption)
                .foregroundStyle(.secondary)
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
        }
    }

    // MARK: - 이메일 로그인/회원가입

    private var emailSection: some View {
        VStack(spacing: 12) {
            TextField("이메일", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("비밀번호 (6자 이상)", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(isRegisterMode ? .newPassword : .password)

            if isRegisterMode {
                SecureField("비밀번호 확인", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)
            }

            // 로그인/회원가입 버튼
            Button {
                handleEmailAuth()
            } label: {
                Text(isRegisterMode ? "회원가입" : "이메일로 로그인")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            // 모드 전환 버튼
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isRegisterMode.toggle()
                    confirmPassword = ""
                }
            } label: {
                Text(isRegisterMode ? "이미 계정이 있으신가요? 로그인" : "계정이 없으신가요? 회원가입")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
    }

    // MARK: - 이메일 인증 처리

    private func handleEmailAuth() {
        if isRegisterMode {
            guard password == confirmPassword else {
                errorMessage = "비밀번호가 일치하지 않습니다."
                showError = true
                return
            }
            let result = authManager.registerWithEmail(email: email, password: password)
            if !result.success {
                errorMessage = result.message
                showError = true
            }
        } else {
            let success = authManager.loginWithEmail(email: email, password: password)
            if !success {
                errorMessage = "이메일 또는 비밀번호가 올바르지 않습니다.\n처음 로그인이라면 회원가입을 해주세요."
                showError = true
            }
        }
    }
}
