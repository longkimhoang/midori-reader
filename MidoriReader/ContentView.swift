//
//  ContentView.swift
//  MidoriReader
//
//  Created by Kim Long on 21/05/2023.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var authCoordinator: AuthCoordinator
  
  var body: some View {
    NavigationStack {
      LoginView()
        .onChange(of: authCoordinator.currentState) { print($0) }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
