//
//  HomeView.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import SwiftUI

struct HomeView: View {
  @StateObject private var _observer = HomeViewObserver.shared
  @State private var _isShowingEditNote = false
  @State private var _selectedNote: MNote? = nil
  @Binding var currentUser: MUser?
  
  init(currentUser: Binding<MUser?>) {
    self._currentUser = currentUser
  }
  
  var body: some View {
    NavigationView {
      List {
        ForEach(_observer.notes, id: \.noid!) { note in
          Button {
            _selectedNote = note
          } label: {
            row(note: note)
              .foregroundColor(.primary)
          }
        }
        .onDelete { indexSet in
          _observer.deleteOneNote(at: indexSet)
        }
      }
      .navigationTitle("Home")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            _isShowingEditNote = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(item: $_selectedNote) { note in
        EditNoteView(note: note, currentUser: $currentUser)
      }
      .sheet(isPresented: $_isShowingEditNote) {
        EditNoteView(note: nil, currentUser: $currentUser)
      }
    }
  }
  
  func row(note: MNote) -> some View {
    HStack {
      VStack(alignment: .leading) {
        Text(note.content)
          .lineLimit(1)
          .font(.title)
        
        HStack {
          Text(note.changedTime!.timeAgoSinceSelf())
            .font(.caption)
          
          Spacer()
          
          Image(systemName: note.wasSynced ? "icloud" : "icloud.slash")
            .font(.caption)
        }
      }
    }
    .contentShape(Rectangle())
  }
}

//struct HomeView_Previews: PreviewProvider {
//  static var previews: some View {
//    HomeView()
//  }
//}
