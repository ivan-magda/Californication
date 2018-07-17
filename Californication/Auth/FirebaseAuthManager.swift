//
//  FirebaseAuthManager.swift
//  Californication
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Ivan Magda. All rights reserved.
//

import Foundation
import FirebaseAuth

enum Result<Value, Error: Swift.Error> {
  case success(Value)
  case error(Error)
}

enum FirebaseAuthError: Swift.Error {
  case anonymousSignInError(Swift.Error)
  case unknown
}

protocol FirebaseAuthManager: class {
  typealias Handler = (Result<User, FirebaseAuthError>) -> Void
  
  func isAuthorized() -> Bool
  func signInAnonymously(_ handler: @escaping Handler)
}
