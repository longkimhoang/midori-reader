//
//  LoginController.swift
//  MidoriReader
//
//  Created by Kim Long on 21/05/2023.
//

import Foundation
import Security
import os.log

@MainActor
class LoginController: ObservableObject {

  struct Credential: Encodable {
    var username: String = ""
    var password: String = ""

    var isValid: Bool {
      !username.isEmpty && !password.isEmpty
    }
  }

  enum Error: LocalizedError {
    case incorrectCredentials
    case unknown(HTTPURLResponse)

    var errorDescription: String? {
      switch self {
      case .incorrectCredentials:
        return String(localized: "Username or password is incorrect.")
      case .unknown(let response):
        return String(
          localized: "Unknown error occured while trying to login (code = \(response.statusCode)).")
      }
    }
  }

  enum StoreKeys {
    static let username = "\(Constants.bundleIdentifier).login.username"
    static let password = "\(Constants.bundleIdentifier).login.password"
  }

  static let shared = LoginController()

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let logger = Logger(subsystem: Constants.bundleIdentifier, category: "Auth")

  @Published var isLoggingIn: Bool = false

  func performLogin(with credential: Credential, storeCredentialsOnSuccess: Bool = false)
    async throws
  {
    isLoggingIn = true
    defer { isLoggingIn = false }

    var request = URLRequest(url: URLConstants.api.appending(path: "login"))
    request.httpMethod = "POST"
    request.httpBody = try encoder.encode(credential)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let response = response as? HTTPURLResponse else { return }

    switch response.statusCode {
    case 200:  // OK
      if storeCredentialsOnSuccess {
        storeCredential(credential)
      }

      let loginResponse = try decoder.decode(LoginResponse.self, from: data)
      print(loginResponse)
    case 401:  // Unauthorized
      throw Error.incorrectCredentials
    default:
      logger.info("Login failed with response \(response)")
      throw Error.unknown(response)
    }
  }

  func storeCredential(_ credential: Credential) {
    // Username is public so we can store in UserDefaults
    UserDefaults.standard.set(credential.username, forKey: StoreKeys.username)

    // Store password in the Keychain
    let addQuery: [String: Any] = [
      kSecClass as String: kSecClassInternetPassword,
      kSecAttrLabel as String: StoreKeys.password,
      kSecAttrAccount as String: credential.username,
      kSecValueData as String: credential.password.data(using: .utf8)!,
      kSecAttrSynchronizable as String: true,
    ]

    let status = SecItemAdd(addQuery as CFDictionary, nil)
    if status != errSecSuccess, let errorMessage = SecCopyErrorMessageString(status, nil) as String?
    {
      // These errors are non-critical to the login flow so we can just report it and move on.
      logger.warning("Cannot save credential to keychain: \(errorMessage)")
    }
  }

  func retrieveStoredCredential() async -> Credential? {
    // Get username
    guard let username = UserDefaults.standard.string(forKey: StoreKeys.username) else {

      return nil
    }

    let retrievePasswordTask: Task<String?, Never> = Task {
      // Get password from Keychain
      let retrieveQuery: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrLabel as String: StoreKeys.password,
        kSecAttrAccount as String: username,
        kSecReturnData as String: true,
      ]

      var result: CFTypeRef?
      let status = SecItemCopyMatching(retrieveQuery as CFDictionary, &result)
      guard status != errSecItemNotFound else { return nil }
      guard status == errSecSuccess, let passwordData = result as? Data,
        let password = String(data: passwordData, encoding: .utf8)
      else {
        if let errorMessage = SecCopyErrorMessageString(status, nil) as String? {
          logger.warning("Cannot save credential to keychain: \(errorMessage)")
        }
        return nil
      }

      return password
    }

    guard let password = await retrievePasswordTask.value else { return nil }
    return Credential(username: username, password: password)
  }
}

typealias LoginCredential = LoginController.Credential
typealias LoginError = LoginController.Error

// MARK: - Preview

// swiftlint:disable:next type_name
class _PreviewLoginController: LoginController {

  override func performLogin(
    with credential: LoginController.Credential, storeCredentialsOnSuccess: Bool = false
  ) async throws {}
}

extension LoginController {
  static let preview: LoginController = _PreviewLoginController()
}
