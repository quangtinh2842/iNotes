//
//  FirebaseManager.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 04/04/2026.
//

import Foundation

class FirebaseManager: NSObject {
  static let shared = FirebaseManager()
  
  private override init() { super.init() }
  
  func allNotesRelatedTo(uid: String, completion handler: @escaping (Error?, [MNote]) -> Void) {
    MNote.query { results, error in
      if error != nil {
        handler(error, [])
      } else {
        let notes = (results as! [MNote]).filter { $0.uid! == uid }
        handler(nil, notes)
      }
    }
  }
  
  func deleteNotes(noteIds: [String], completion handler: ((Error?) -> Void)?) {
    let group = DispatchGroup()
    var lastError: Error?
    
    for noteId in noteIds {
      group.enter()
      
      MNote.deleteWithId(noteId) { error in
        if error != nil {
          lastError = error
        }
        
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
      handler?(lastError)
    }
  }
}
