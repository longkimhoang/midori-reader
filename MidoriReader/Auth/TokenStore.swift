//
//  TokenStore.swift
//  MidoriReader
//
//  Created by Kim Long on 29/05/2023.
//

import Combine
import Factory
import Foundation
import KeychainSwift

private let entryKeychainLabel = "auth.token"

enum TokenType {
  case accessToken
  case refreshToken
}

protocol TokenStoreType {
  func store(accessToken: String, refreshToken: String) async
  func retrieveAccessToken() async throws -> (String?, canRefresh: Bool)
  
  var tokenExpiredPublisher: AnyPublisher<TokenType, Never> { get }
}

actor TokenStore: TokenStoreType {
  
  struct Entry: Codable {
    let timestamp: Date
    let accessToken: String
    let refreshToken: String
  }
  
  enum TokenLifetime {
    static let accessToken: TimeInterval = 15 * 60
    static let refreshToken: TimeInterval = 30 * 24 * 60 * 60
  }
  
  private let tokenExpiredSubject = PassthroughSubject<TokenType, Never>()
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  
  @Injected(\.keychain) var keychain
  
  func store(accessToken: String, refreshToken: String) async {
    let entry = Entry(timestamp: Date(), accessToken: accessToken, refreshToken: refreshToken)
    guard let data = try? encoder.encode(entry) else { return }
    keychain.set(data, forKey: entryKeychainLabel)
  }
  
  func retrieveAccessToken() async throws -> (String?, canRefresh: Bool) {
    let entry = try keychain.getData(entryKeychainLabel).map { try decoder.decode(Entry.self, from: $0) }
    guard let entry else { return (nil, false) }
    
    let now = Date()
    if entry.timestamp.advanced(by: TokenLifetime.accessToken) > now {
      // Token is still valid
      return (entry.accessToken, true)
    } else if entry.timestamp.advanced(by: TokenLifetime.refreshToken) > now {
      // Refresh token is still valid
      tokenExpiredSubject.send(.accessToken)
      return (nil, true)
    } else {
      tokenExpiredSubject.send(.refreshToken)
      return (nil, false)
    }
  }
  
  nonisolated var tokenExpiredPublisher: AnyPublisher<TokenType, Never> {
    tokenExpiredSubject.eraseToAnyPublisher()
  }
}

extension Container {
  var tokenStore: Factory<TokenStoreType> {
    self { TokenStore() }
  }
}
