//
//  UserView.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import SwiftUI
import Kingfisher
import AlertToast

struct ProfileView: View {
  @StateObject private var _observer: ProfileViewObserver
  @Binding var currentUser: MUser?
  
  @State private var _showToast = false
  @State private var _toast: AlertToast = AlertToast(type: .regular)
  
  init(currentUser: Binding<MUser?>) {
    self._currentUser = currentUser
    self.__observer = StateObject(wrappedValue: ProfileViewObserver(currentUser: currentUser.wrappedValue!))
  }
  
  var body: some View {
    NavigationView {
      List {
        Section {
          HStack(spacing: 10) {
            KFImage(URL(string: _observer.currentUser.photoURL ?? "") ?? URL(string: "https://raw.githubusercontent.com/quangtinh2842/PublicStore/refs/heads/main/Icons/account_circle_1000dp_434343_FILL0_wght400_GRAD0_opsz48.png"))
              .placeholder {
                Image(systemName: "person.circle.fill")
                  .foregroundColor(.gray)
              }
              .resizable()
              .cacheOriginalImage()
              .scaledToFill()
              .frame(width: 60, height: 60)
              .clipShape(Circle())
            
            VStack(alignment: .leading) {
              Text(_observer.currentUser.email!)
                .font(.title3)
                .foregroundColor(Color(.label))
            }
          }
        } footer: {
          Text("UID: "+_observer.currentUser.uid!)
        }
        
        Section(header: Text("Support & About")) {
          Button {
            
          } label: {
            HStack(spacing: 16) {
              Image(systemName: "questionmark.circle")
                .foregroundColor(Color(.gray))
              Text("Help & Support")
                .foregroundColor(Color(.label))
                .fontWeight(.medium)
            }
          }
          
          NavigationLink(destination: TOSView()) {
            HStack(spacing: 16) {
              Image(systemName: "doc.text")
                .foregroundColor(Color(.gray))
              Text("Terms of Service")
                .foregroundColor(Color(.label))
                .fontWeight(.medium)
            }
          }
        }
        
        Section(header: Text("Development")) {
          NavigationLink(destination: ResourcesView()) {
            HStack(spacing: 16) {
              Image(systemName: "heart")
                .foregroundColor(Color(.gray))
              Text("Resources")
                .foregroundColor(Color(.label))
                .fontWeight(.medium)
            }
          }
        }
        
        Section(header: Text("Actions")) {
          Button {
            _handleLogOutButton()
          } label: {
            HStack(spacing: 16) {
              Image(systemName: "rectangle.portrait.and.arrow.right")
                .foregroundColor(Color(.gray))
              Text("Log out")
                .foregroundColor(Color(.label))
                .fontWeight(.medium)
            }
          }
        }
      }
      .navigationTitle("Profile")
      .toast(isPresenting: $_showToast, alert: {
        return _toast
      })
    }
  }
  
  private func _handleLogOutButton() {
    do {
      try MUser.signOutEverywhere()
      self.currentUser = nil
    } catch {
      _toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: error.localizedDescription)
      _showToast = true
    }
  }
}
