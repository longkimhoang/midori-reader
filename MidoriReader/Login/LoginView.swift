//
//  LoginView.swift
//  MidoriReader
//
//  Created by Kim Long on 21/05/2023.
//

import SwiftUI

struct LoginCredential {
  var username = ""
  var password = ""
  
  var isValid: Bool {
    !username.isEmpty && !password.isEmpty
  }
}

struct LoginView: View {
  
  @State private var credential = LoginCredential()
  @State private var rememberLogin: Bool = false
  @State private var loading: Bool = false
  
  @Environment(\.openURL) var openURL
  
  var body: some View {
    let prompt = Text("Required")
    
    Form {
      Section {
        TextField("Username", text: $credential.username, prompt: prompt)
          .textContentType(.username)
        
        SecureField("Password", text: $credential.password, prompt: prompt)
          .textContentType(.password)
        
        Toggle("Remember login", isOn: $rememberLogin)
      } footer: {
#if os(macOS)
        registerHelperText
#endif
      }
    }
    .safeAreaInset(edge: .bottom, alignment: .trailing) {
#if os(macOS)
      HStack {
        if loading {
          ProgressView()
            .controlSize(.small)
            .padding(.trailing, 2)
        }
        registerButton
        loginButton
      }
#else
      VStack {
        loginButton
        registerButton
        registerHelperText
          .font(.footnote)
          .multilineTextAlignment(.center)
          .padding(.top, 4)
      }
      .padding()
      .background(.background)
      .controlSize(.large)
#endif
    }
#if os(macOS)
    .padding()
#endif
    .navigationTitle("Login")
    .toolbar {
#if os(iOS)
      if loading {
        ToolbarItem(placement: .automatic) {
          ProgressView()
            .controlSize(.regular)
        }
      }
#endif
    }
    .disabled(loading)
  }
  
  var loginButton: some View {
    Button {
      loading.toggle()
    } label: {
      Text("Login")
#if os(iOS)
        .frame(maxWidth: .infinity)
#endif
    }
    .disabled(!credential.isValid)
    .buttonStyle(.borderedProminent)
  }
  
  var registerButton: some View {
    Button {
      if let url = URL(string: "https://mangadex.org") {
        openURL(url)
      }
    } label: {
      Text("Register")
#if os(iOS)
        .frame(maxWidth: .infinity)
#endif
    }
    .buttonStyle(.bordered)
    .accessibilityHint("Create an account on the MangaDex website")
  }
  
  @ViewBuilder
  var registerHelperText: some View {
    let message: LocalizedStringKey =
    """
    Choose "Register" to create an account on the MangaDex website.
    """
    
    Text(message)
      .foregroundColor(.secondary)
      .accessibilityHidden(true)
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      LoginView()
    }
  }
}
