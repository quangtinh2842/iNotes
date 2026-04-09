//
//  ProfileViewObserver.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import Foundation

class ProfileViewObserver: NSObject, ObservableObject {
  @Published var currentUser: MUser
    
  init(currentUser: MUser) {
    self.currentUser = currentUser
  }
}
