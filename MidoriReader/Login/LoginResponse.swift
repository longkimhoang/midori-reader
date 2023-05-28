//
//  LoginResponse.swift
//  MidoriReader
//
//  Created by Kim Long on 24/05/2023.
//

import Foundation

struct LoginResponse: Codable {
  let accessToken: String
  let refreshToken: String
  
  enum CodingKeys: String, CodingKey {
    case result
    case token
  }
  
  enum TokenCodingKeys: String, CodingKey {
    case session
    case refresh
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let result = try container.decode(String.self, forKey: .result)
    guard result == "ok" else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "result must be ok"))
    }
    
    let tokenContainer = try container.nestedContainer(keyedBy: TokenCodingKeys.self, forKey: .token)
    accessToken = try tokenContainer.decode(String.self, forKey: .session)
    refreshToken = try tokenContainer.decode(String.self, forKey: .refresh)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: TokenCodingKeys.self)
    try container.encode(accessToken, forKey: .session)
    try container.encode(refreshToken, forKey: .refresh)
  }
}
