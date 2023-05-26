//
//  LoginController.swift
//  MidoriReader
//
//  Created by Kim Long on 21/05/2023.
//

import Foundation
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
        return String(localized: "Unknown error occured while trying to login (code = \(response.statusCode)).")
      }
    }
  }
  
  static let shared = LoginController()
  
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let logger = Logger(subsystem: Bundle.main.bundleURL.absoluteString, category: "Auth")
  
  @Published var isLoggingIn: Bool = false
  
  func performLogin(with credential: Credential) async throws {
    var request = URLRequest(url: URLConstants.api.appending(path: "login"))
    request.httpMethod = "POST"
    request.httpBody = try encoder.encode(credential)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    isLoggingIn = true
    let (data, response) = try await URLSession.shared.data(for: request)
    isLoggingIn = false
    
    guard let response = response as? HTTPURLResponse else { return }
    
    switch response.statusCode {
    case 200: // OK
      let loginResponse = try decoder.decode(LoginResponse.self, from: data)
      print(loginResponse)
    case 401: // Unauthorized
      throw Error.incorrectCredentials
    default:
      logger.info("Login failed with response \(response)")
      throw Error.unknown(response)
    }
  }
}

typealias LoginCredential = LoginController.Credential
typealias LoginError = LoginController.Error

// MARK: - Preview

class _PreviewLoginController: LoginController {
  
  override func performLogin(with credential: LoginController.Credential) async throws {}
}

extension LoginController {
  static let preview: LoginController = _PreviewLoginController()
}
