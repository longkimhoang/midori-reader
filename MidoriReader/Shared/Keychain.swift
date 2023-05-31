//
//  Keychain.swift
//  MidoriReader
//
//  Created by Kim Long on 31/05/2023.
//

import Factory
import Foundation
import KeychainSwift
import Security

@globalActor
actor KeychainActor {
  static var shared = KeychainActor()
}

extension Container {
  var keychain: Factory<KeychainSwift> {
    self {
      let keychain = KeychainSwift()
      keychain.synchronizable = true

      return keychain
    }
    .context(.test) {
      KeychainSwift(keyPrefix: "unittest_")
    }
  }
}
