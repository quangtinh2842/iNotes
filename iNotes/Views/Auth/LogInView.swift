//
//  LogInView.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import SwiftUI
import HUD
import AlertToast
import FirebaseAuth

struct LogInView: View {
  @StateObject private var _observer = LogInViewObserver()
  
  @Binding var currentUser: MUser?
  
  enum Field {
    case email
    case password
  }
  
  @FocusState private var _focusedField: Field?
  
  @State private var _showToast = false
  @State private var _toast: AlertToast = AlertToast(type: .regular)
  
  @State private var _hudState: HUDState?
  
  var body: some View {
    VStack {
      Spacer()
      
      Image("Logo")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 130, height: 130)
        .clipped()
        .cornerRadius(8)
        .padding(.bottom, 24)
      
      Text("Log in to your Account")
        .font(.system(size: 24, weight: .medium))
        .padding(.bottom, 4)
      Text("Please enter your details.")
        .font(.system(size: 14, weight: .light))
        .padding(.bottom, 24)
      
      TextField("Enter your email", text: $_observer.email)
        .focused($_focusedField, equals: .email)
        .submitLabel(.next)
        .onSubmit {
          _focusedField = .password
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.clear)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color(.systemGray), lineWidth: 1)
        )
        .foregroundColor(Color(.label))
        .padding(.bottom, 16)
      
      SecureField("Enter your password", text: $_observer.password)
        .focused($_focusedField, equals: .password)
        .submitLabel(.done)
        .onSubmit {
          _focusedField = nil
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.clear)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color(.systemGray), lineWidth: 1)
        )
        .foregroundColor(Color(.label))
        .padding(.bottom, 16)
      
      Button {
        _handleLogInButton()
      } label: {
        Text("Log in")
          .foregroundColor(Color.white)
          .padding(.vertical, 16)
          .frame(maxWidth: .infinity)
          .background(Color(.tintColor))
          .cornerRadius(8)
          .font(.system(size: 18))
      }
      
      Spacer()
    }
    .padding(.horizontal, 32)
    .toast(isPresenting: $_showToast, alert: {
      return _toast
    })
    .overlayHUD($_hudState)
  }
  
  private func _handleLogInButton() {
    if _observer.email.isEmpty {
      _toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: "Email Address is empty.")
      _showToast = true
      return
    }
    
    if _observer.password.isEmpty {
      _toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: "Password is empty.")
      _showToast = true
      return
    }
    
    _hudState = .loading()
    Auth.auth().signIn(withEmail: _observer.email, password: _observer.password) { result, error in
      _hudState = nil
      
      if error != nil {
        _toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: "Logging in error: "+error!.localizedDescription)
        _showToast = true
      } else {
        _hudState = .loading()
        processAfterSignIn { error2 in
          _hudState = nil
          
          if error2 != nil {
            _toast = AlertToast(displayMode: .banner(.pop), type: .error(.red), title: "Error", subTitle: "Logging in error: "+error2!.localizedDescription)
            _showToast = true
          } else {
            let authCurrentUser = Auth.auth().currentUser!
            let mUser = MUser(authUser: authCurrentUser)
            self.currentUser = mUser
          }
        }
      }
    }
  }
}
