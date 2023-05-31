//
//  AuthCoordinator.swift
//  MidoriReader
//
//  Created by Kim Long on 31/05/2023.
//

import Combine
import Factory
import Foundation

enum AuthState {
  case notDetermined
  case unauthenticated
  case authenticated
}

@MainActor
final class AuthCoordinator: ObservableObject {

  private var cancellables: Set<AnyCancellable> = []

  @Published var currentState: AuthState = .notDetermined

  @Injected(\.tokenStore) var tokenStore

  func retrieveInitialAuthState() async {
    setupSubscribers()
  }

  func didFinishLogin() {
    currentState = .authenticated
  }

  private func setupSubscribers() {
    tokenStore.tokenExpiredPublisher
      .compactMap {
        $0 == .refreshToken ? AuthState.unauthenticated : nil
      }
      .assign(to: &$currentState)
  }
}

@MainActor
extension Container {
  var authCoordinator: Factory<AuthCoordinator> {
    self { AuthCoordinator() }
  }
}
