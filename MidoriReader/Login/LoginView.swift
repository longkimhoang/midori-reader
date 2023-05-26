//
//  LoginView.swift
//  MidoriReader
//
//  Created by Kim Long on 21/05/2023.
//

import SwiftUI

struct LoginView: View {
  
  enum Field: Int {
    case username, password
  }
  
  @State private var credential = LoginCredential()
  @State private var loginError: LoginError?
  @State private var showAlert = false
  
  @FocusState private var focusedField: Field?
  @AccessibilityFocusState private var loadingFocused: Bool
  
  @ObservedObject var loginController: LoginController
  
  init(controller: LoginController = .shared) {
    self.loginController = controller
  }
  
  var body: some View {
    Form {
      Section {
        Text("Midori")
          .font(.largeTitle)
          .fontDesign(.serif)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
      }
      .listRowBackground(Color.clear)
      
      Section {
        TextField("Username", text: $credential.username)
          .textContentType(.username)
          .textInputAutocapitalization(.never)
          .focused($focusedField, equals: .username)
        
        SecureField("Password", text: $credential.password)
          .textContentType(.password)
          .focused($focusedField, equals: .password)
      }
      
      Section {
        Button("Login", action: performLogin)
          .disabled(!credential.isValid)
        
        Link("Register", destination: URL(string: "https://mangadex.org")!)
      } footer: {
        Text("Choose \"Register\" to create an account on the MangaDex website.")
      }
    }
    .disabled(loginController.isLoggingIn)
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.hidden, for: .navigationBar)
    .toolbar {
      ToolbarItem {
        ProgressView()
          .opacity(loginController.isLoggingIn ? 1 : 0)
          .animation(.default, value: loginController.isLoggingIn)
          .accessibilityFocused($loadingFocused)
      }
    }
    .onSubmit {
      guard credential.isValid else { return }
      
      performLogin()
    }
    .onChange(of: loginController.isLoggingIn) {
      loadingFocused = $0
    }
    .alert(isPresented: $showAlert, error: loginError) {}
    .scrollBounceBehavior(.basedOnSize)
  }
  
  func performLogin() {
    Task {
      do {
        try await loginController.performLogin(with: credential)
      } catch let error as LoginError {
        loginError = error
        showAlert = true
      } catch {
        fatalError("Unhandled error: \(error.localizedDescription)")
      }
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LoginView(controller: .preview)
    }
  }
}
