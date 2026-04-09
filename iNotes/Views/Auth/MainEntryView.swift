//
//  MainEntryView.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import SwiftUI
import AlertToast

struct MainEntryView: View {
  @Binding var currentUser: MUser?
  
  @State var showToast = false
  @State var toast: AlertToast = AlertToast(displayMode: .hud, type: .systemImage("wifi.slash", .yellow), subTitle: "No network connection.")
  
  var body: some View {
    VStack {
      if currentUser != nil {
        MainTabView(currentUser: $currentUser)
      } else {
        LogInView(currentUser: $currentUser)
      }
    }
    .toast(isPresenting: $showToast, duration: .infinity, tapToDismiss: false, alert: {
      return toast
    })
    .onAppear {
      ReachabilityHelper.shared.setupReachability { connected in
        self.showToast = !connected
        
        if connected {
          HomeViewObserver.shared.syncForFirebaseIfHasNoSyncedYet()
        }
      }
    }
  }
}
