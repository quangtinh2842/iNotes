//
//  MainTabView.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import SwiftUI

struct MainTabView: View {
  @Binding var currentUser: MUser?
  
  var body: some View {
    TabView {
      HomeView(currentUser: $currentUser)
        .tabItem {
          Label("", systemImage: "house.fill")
        }
      
      ProfileView(currentUser: $currentUser)
        .tabItem {
          Label("", systemImage: "person.crop.circle.fill")
        }
    }
  }
}

//struct MainTabView_Previews: PreviewProvider {
//  static var previews: some View {
//    MainTabView()
//  }
//}
