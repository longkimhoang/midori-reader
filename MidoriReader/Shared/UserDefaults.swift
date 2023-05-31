//
//  UserDefaults.swift
//  MidoriReader
//
//  Created by Kim Long on 31/05/2023.
//

import Factory
import Foundation

extension Container {
  /// The `UserDefaults` to use.
  ///
  /// Tests should inject their own suites in `setUp` and clear them in `tearDown`.
  var userDefaults: Factory<UserDefaults> {
    self { UserDefaults.standard }
  }
}
