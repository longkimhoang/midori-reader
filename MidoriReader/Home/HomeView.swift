//
//  HomeView.swift
//  MidoriReader
//
//  Created by Kim Long on 31/05/2023.
//

import SwiftUI

struct HomeView: View {
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
      
      Text("History")
        .tabItem {
          Label("History", systemImage: "clock.arrow.circlepath")
        }
      
      Text("Search")
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
