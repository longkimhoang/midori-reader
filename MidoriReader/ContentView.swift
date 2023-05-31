//
//  ContentView.swift
//  MidoriReader
//
//  Created by Kim Long on 21/05/2023.
//

import Factory
import SwiftUI

struct ContentView: View {
  @EnvironmentObject var authCoordinator: AuthCoordinator

  var body: some View {
    Group {
      if authCoordinator.currentState == .authenticated {
        NavigationStack {
          HomeView()
        }
      } else {
        NavigationStack {
          LoginView()
            .onChange(of: authCoordinator.currentState) { print($0) }
        }
      }
    }
    .animation(.default, value: authCoordinator.currentState)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(Container.shared.authCoordinator())
  }
}
