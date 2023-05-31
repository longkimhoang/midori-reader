//
//  HomeView.swift
//  MidoriReader
//
//  Created by Kim Long on 31/05/2023.
//

import Factory
import SwiftUI

struct HomeView: View {
  @EnvironmentObject var authCoordinator: AuthCoordinator

  var body: some View {
    TabView {
      Text("Feed")
        .tabItem {
          Label("Feed", systemImage: "house")
        }

      Text("Updates")
        .tabItem {
          Label("Updates", systemImage: "newspaper")
        }
      
      Text("Library")
        .tabItem {
          Label("Library", systemImage: "books.vertical")
        }

      Text("History")
        .tabItem {
          Label("History", systemImage: "clock.arrow.circlepath")
        }

      Text("Search")
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
    }
    .toolbar {
      ToolbarItem {
        Button("Logout") {
          authCoordinator.currentState = .unauthenticated
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      HomeView()
        .environmentObject(Container.shared.authCoordinator())
    }
  }
}
