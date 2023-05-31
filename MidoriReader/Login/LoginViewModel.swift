//
//  LoginViewModel.swift
//  MidoriReader
//
//  Created by Kim Long on 30/05/2023.
//

import Alamofire
import Combine
import Factory
import Foundation
import os.log
import Security

private let usernameDefaultsLabel = "login.username"
private let passwordKeychainLabel = "login.password"

@MainActor
final class LoginViewModel: ObservableObject {

  typealias Credential = LoginCredential
  
  private let loginErrorSubject = PassthroughSubject<LoginError, Never>()
  private let logger = Logger(subsystem: Constants.bundleIdentifier, category: "Login")

  @Published var credential = Credential(username: "", password: "")
  @Published var storePasswordInKeychain = false
  @Published var isLoggingIn = false

  @Injected(\.performLogin) var performLogin
  @Injected(\.keychain) var keychain
  @Injected(\.userDefaults) var userDefaults
  @Injected(\.tokenStore) var tokenStore

  func retrieveStoredCredential() async {
    var restoredCredential = Credential(username: "", password: "")
    
    if let username = userDefaults.string(forKey: usernameDefaultsLabel) {
      restoredCredential.username = username
    }
    
    if let password = await retrievePasswordFromKeychain() {
      restoredCredential.password = password
    }
    
    credential = restoredCredential
  }

  func login() async {
    isLoggingIn = true
    defer { isLoggingIn = false }
    
    let result = await performLogin(credential)
    switch result {
    case .success(let response):
      userDefaults.set(credential.username, forKey: usernameDefaultsLabel)
      let storePasswordResult = keychain.set(credential.password, forKey: passwordKeychainLabel)
      if !storePasswordResult, let errorMessage = SecCopyErrorMessageString(keychain.lastResultCode, nil) as String? {
        logger.warning("Cannot store password: \(errorMessage)")
      }
      
      await tokenStore.store(accessToken: response.accessToken, refreshToken: response.refreshToken)
    case .failure(let error):
      loginErrorSubject.send(error)
    }
  }
  
  var loginErrorPublisher: some Publisher<LoginError, Never> { loginErrorSubject }
  
  @KeychainActor
  private func retrievePasswordFromKeychain() async -> String? {
    await keychain.get(passwordKeychainLabel)
  }
}

extension LoginViewModel.Credential {
  var isValid: Bool {
    !username.isEmpty && !password.isEmpty
  }
}

@MainActor
extension Container {
  var loginViewModel: Factory<LoginViewModel> {
    self { LoginViewModel() }
  }
}
