//
//  FirebaseAuthManagerImpl.swift
//  Californication
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Ivan Magda. All rights reserved.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthManagerImpl: FirebaseAuthManager {
  
  func isAuthorized() -> Bool {
    return Auth.auth().currentUser != nil
  }
  
  func signInAnonymously(_ handler: @escaping (Result<User, FirebaseAuthError>) -> Void) {
    Auth.auth().signInAnonymously { (result, error) in
      if let error = error {
        print("Error: \(error.localizedDescription) \(#file) \(#function)")
        handler(.error(.anonymousSignInError(error)))
      } else if let result = result {
        handler(.success(result.user))
      } else {
        handler(.error(.unknown))
      }
    }
  }
  
}
