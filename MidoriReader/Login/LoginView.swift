//
//  LoginView.swift
//  MidoriReader
//
//  Created by Kim Long on 21/05/2023.
//

import Combine
import Factory
import SwiftUI

struct LoginView: View {

  enum Field: Int {
    case username, password
  }

  @State private var storeCredentialsInKeychain = false
  @State private var loginError: LoginError?
  @State private var showAlert = false
  @StateObject private var viewModel = Container.shared.loginViewModel()
  @FocusState private var focusedField: Field?
  @AccessibilityFocusState private var loadingFocused: Bool

  @EnvironmentObject var authCoordinator: AuthCoordinator

  var body: some View {
    Form {
      Section {
        Text(verbatim: "Midori")
        .font(.largeTitle)
        .fontDesign(.serif)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
      }
      .listRowBackground(Color.clear)

      Section {
        TextField("Username", text: $viewModel.credential.username)
        .textContentType(.username)
        .focused($focusedField, equals: .username)
        #if os(iOS)
        .textInputAutocapitalization(.never)
        #endif

        SecureField("Password", text: $viewModel.credential.password)
        .textContentType(.password)
        .focused($focusedField, equals: .password)
      }

      Section {
        Toggle("Store password in Keychain", isOn: $viewModel.storePasswordInKeychain)
      } footer: {
        Text(
          "If a password is found in the Keychain on the next login attempt, it would be filled in."
        )
      }

      Section {
        Button("Login", action: performLogin)
        .disabled(!viewModel.credential.isValid)

        Link("Register", destination: URLConstants.homepage)
      } footer: {
        Text("Choose \"Register\" to create an account on the MangaDex website.")
      }
    }
    .task {
      await viewModel.retrieveStoredCredential()
    }
    .disabled(viewModel.isLoggingIn)
    #if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.hidden, for: .navigationBar)
    #endif
    .toolbar {
      ToolbarItem {
        ProgressView()
          .opacity(viewModel.isLoggingIn ? 1 : 0)
          .animation(.default, value: viewModel.isLoggingIn)
          .accessibilityFocused($loadingFocused)
      }
    }
    .onSubmit {
      guard viewModel.credential.isValid else { return }

      performLogin()
    }
    .onChange(of: viewModel.isLoggingIn) {
      loadingFocused = $0
    }
    .alert(isPresented: $showAlert, error: loginError) {}
    .scrollBounceBehavior(.basedOnSize)
  }

  func performLogin() {
    Task {
      let result = await viewModel.login()
      switch result {
      case .success:
        authCoordinator.didFinishLogin()
      case .failure(let error):
        loginError = error
        showAlert = true
      }
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LoginView()
    }
  }
}
