//
//  EditNoteViewObserver.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 04/04/2026.
//

import Foundation
import RealmSwift

class EditNoteViewObserver: NSObject, ObservableObject {
  @Published var noid: String
  @Published var uid: String
  @Published var content: String
  @Published var createdTime: Date
  @Published var changedTime: Date
  @Published var wasSynced: Bool
  
  var editingNote: MNote {
    return MNote(noid: noid, uid: uid, content: content, createdTime: createdTime, changedTime: changedTime, wasSynced: wasSynced)
  }
  
  init(note: MNote?, currentUser: MUser) {
    if note != nil {
      self.noid = note!.noid!
      self.uid = note!.uid!
      self.content = note!.content
      self.createdTime = note!.createdTime!
      self.changedTime = note!.changedTime!
      self.wasSynced = note!.wasSynced
    } else {
      self.noid = MNote.getAutoId()
      self.uid = currentUser.uid!
      self.content = ""
      self.createdTime = Date()
      self.changedTime = Date()
      self.wasSynced = false
    }
  }
}
