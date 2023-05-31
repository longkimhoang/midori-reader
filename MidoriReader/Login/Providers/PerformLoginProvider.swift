//
//  PerformLoginProvider.swift
//  MidoriReader
//
//  Created by Kim Long on 30/05/2023.
//

import Alamofire
import Factory
import Foundation

private let apiLoginURL = URLConstants.api.appending(path: "login")

enum LoginError: LocalizedError {
  case incorrectCredentials
  case generic(underlyingError: Error)

  var errorDescription: String? {
    switch self {
    case .incorrectCredentials:
      return String(localized: "Username or password is incorrect.")
    case .generic(let underlyingError):
      return String(
        localized:
          "Unknown error occured while trying to login \(underlyingError.localizedDescription).")
    }
  }
}

typealias PerformLogin = (_ credential: LoginCredential) async -> Result<LoginResponse, LoginError>

@MainActor
extension Container {
  var performLogin: Factory<PerformLogin> {
    self {
      { credential in
        let dataTask = AF.request(apiLoginURL, method: .post, parameters: credential, encoder: .json)
          .validate(statusCode: CollectionOfOne(200))
          .serializingDecodable(LoginResponse.self)

        return await dataTask.result
          .mapError { error in
            switch error {
            case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401)):
              return LoginError.incorrectCredentials
            default:
              return LoginError.generic(underlyingError: error)
            }
          }
      }
    }
  }
}
