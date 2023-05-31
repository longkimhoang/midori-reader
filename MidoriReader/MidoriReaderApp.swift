//
//  MidoriReaderApp.swift
//  MidoriReader
//
//  Created by Kim Long on 21/05/2023.
//

import Factory
import SwiftUI

@main
struct MidoriReaderApp: App {
  @StateObject private var authCoordinator = Container.shared.authCoordinator()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authCoordinator)
        .task {
          await authCoordinator.retrieveInitialAuthState()
        }
    }
  }
}
