//
//  EditNoteView.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import SwiftUI
import RealmSwift

struct EditNoteView: View {
  @StateObject private var _observer: EditNoteViewObserver
  @Binding var currentUser: MUser?
  var note: MNote?
  
  @FocusState private var _isFocused: Bool
  
  init(note: MNote? = nil, currentUser: Binding<MUser?>) {
    self.__observer = StateObject(wrappedValue: EditNoteViewObserver(note: note, currentUser: currentUser.wrappedValue!))
    self._currentUser = currentUser
    self.note = note
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        VStack(alignment: .leading) {
          ZStack(alignment: .topLeading) {
            Text(_observer.content)
              .foregroundColor(.clear)
              .padding(8)
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(GeometryReader { proxy in
                Color.clear
              })
            
            TextEditor(text: $_observer.content)
              .frame(minHeight: 40)
              .opacity(_observer.content.isEmpty ? 0.25 : 1)
              .focused($_isFocused)
              .onChange(of: _observer.content) { newValue in
                _observer.changedTime = Date()
              }
          }
          .padding(4)
          .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
        }
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom, 0)
        
        Text(_observer.changedTime.toNoteFootTimestamp())
          .font(.footnote)
          .padding(.vertical, 4)
          .foregroundColor(.secondary)
      }
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button {
            _isFocused = false
          } label: {
            Image(systemName: "keyboard.chevron.compact.down")
          }
        }
      }
      .onDisappear {
        let editingNote = _observer.editingNote
        if editingNote.validate() == (.Valid, nil) {
          if self.note != nil {
            let group = DispatchGroup()
            
            group.enter()
            try! RealmManager.sharedManager.realmInstance.write {
              self.note?.content = editingNote.content
              self.note?.changedTime = editingNote.changedTime
              group.leave()
            }
            group.notify(queue: .main) {
              HomeViewObserver.shared.updateNoteForAll(self.note!)
            }
          } else {
            HomeViewObserver.shared.updateNoteForAll(editingNote)
          }
        }
      }
    }
  }
}

//struct EditNoteView_Previews: PreviewProvider {
//  static var previews: some View {
//    EditNoteView()
//  }
//}
