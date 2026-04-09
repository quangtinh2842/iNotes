//
//  UserDefaultsHelper.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 04/04/2026.
//

import Foundation

class UserDefaultsHelper {
  static let shared = UserDefaultsHelper()
  
  private init() {}
  
  func markSavedOnDeviceEverToTrueFor(uid: String) {
    let key = uid + "_saved-on-device-ever"
    UserDefaults.standard.set(true, forKey: key)
  }
  
  func hasSavedOnDeviceEverFor(uid: String) -> Bool {
    let key = uid + "_saved-on-device-ever"
    let value = UserDefaults.standard.object(forKey: key) as? Bool
    return value ?? false
  }
}
