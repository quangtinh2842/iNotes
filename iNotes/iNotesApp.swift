//
//  iNotesApp.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 01/04/2026.
//

import SwiftUI
import FirebaseCore
import AlertToast
import FirebaseAuth
import RealmSwift

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct iNotesApp: SwiftUI.App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  @State private var _currentUser: MUser?
  
  @State private var _showToast: Bool = false
  @State private var _toast: AlertToast = AlertToast(displayMode: .hud, type: .loading)
  
  var body: some Scene {
    WindowGroup {
      MainEntryView(currentUser: $_currentUser)
        .environment(\.realmConfiguration, Realm.Configuration())
        .onAppear {
          if let currentUser = MUser.getCurrentUser() {
            _currentUser = currentUser
            processAfterSignIn { error in
            }
          }
        }
    }
  }
}
