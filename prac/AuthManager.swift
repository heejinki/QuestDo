//
//  AuthManager.swift
//  prac
//
//  인증 상태 관리 (로그인/로그아웃)
//

import SwiftUI

// MARK: - 로그인 방식

enum AuthProvider: String, Codable {
    case email
    case kakao
    case naver
    case google
    case apple
}

// MARK: - 인증 매니저

@Observable
class AuthManager {
    var isLoggedIn: Bool = false
    var isAdmin: Bool = false
    var currentUserEmail: String = ""
    var authProvider: AuthProvider? = nil

    private let loggedInKey = "auth_is_logged_in"
    private let emailKey = "auth_user_email"
    private let providerKey = "auth_provider"

    init() {
        // 저장된 로그인 상태 복원
        isLoggedIn = UserDefaults.standard.bool(forKey: loggedInKey)
        currentUserEmail = UserDefaults.standard.string(forKey: emailKey) ?? ""
        if let raw = UserDefaults.standard.string(forKey: providerKey) {
            authProvider = AuthProvider(rawValue: raw)
        }
    }

    // MARK: 이메일 로그인 (로컬 저장)

    func loginWithEmail(email: String, password: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        guard isValidEmail(trimmedEmail) else { return false }
        guard password.count >= 6 else { return false }

        // 로컬: 저장된 계정 확인 또는 자동 생성
        let accounts = loadAccounts()
        if let stored = accounts[trimmedEmail] {
            guard stored == password else { return false }
        }

        completeLogin(email: trimmedEmail, provider: .email)
        return true
    }

    // MARK: 이메일 회원가입

    func registerWithEmail(email: String, password: String) -> (success: Bool, message: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        guard isValidEmail(trimmedEmail) else {
            return (false, "올바른 이메일 형식이 아닙니다.")
        }
        guard password.count >= 6 else {
            return (false, "비밀번호는 6자 이상이어야 합니다.")
        }

        var accounts = loadAccounts()
        guard accounts[trimmedEmail] == nil else {
            return (false, "이미 가입된 이메일입니다.")
        }

        accounts[trimmedEmail] = password
        saveAccounts(accounts)
        completeLogin(email: trimmedEmail, provider: .email)
        return (true, "")
    }

    // MARK: 소셜 로그인 (UI만 구성, 실제 SDK 연동 필요)

    func loginWithSocial(_ provider: AuthProvider) {
        // 실제 구현 시 각 SDK 연동 필요
        // 현재는 데모용으로 즉시 로그인 처리
        let demoEmail = "\(provider.rawValue)_user@demo.com"
        completeLogin(email: demoEmail, provider: provider)
    }

    // MARK: 관리자 인증

    func verifyAdmin(password: String) -> Bool {
        if password == "4268" {
            isAdmin = true
            return true
        }
        return false
    }

    func exitAdmin() {
        isAdmin = false
    }

    // MARK: 로그아웃

    func logout() {
        isLoggedIn = false
        isAdmin = false
        currentUserEmail = ""
        authProvider = nil
        UserDefaults.standard.set(false, forKey: loggedInKey)
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: providerKey)
    }

    // MARK: 내부 헬퍼

    private func completeLogin(email: String, provider: AuthProvider) {
        currentUserEmail = email
        authProvider = provider
        isLoggedIn = true
        UserDefaults.standard.set(true, forKey: loggedInKey)
        UserDefaults.standard.set(email, forKey: emailKey)
        UserDefaults.standard.set(provider.rawValue, forKey: providerKey)
    }

    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }

    // 로컬 계정 저장/불러오기
    private let accountsKey = "auth_accounts"

    private func loadAccounts() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey),
              let accounts = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return accounts
    }

    private func saveAccounts(_ accounts: [String: String]) {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        UserDefaults.standard.set(data, forKey: accountsKey)
    }
}
