//
//  LogInViewObserver.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import Foundation

class LogInViewObserver: NSObject, ObservableObject {
  @Published var email: String = "quangtinh2842@gmail.com"
  @Published var password: String = "1212345678"
}
