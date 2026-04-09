//
//  RealmManager.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 04/04/2026.
//

import Foundation
import RealmSwift
import FirebaseAuth

class RealmManager: NSObject {
  // Singleton declarations
  static var sharedManager = RealmManager()
  fileprivate override init() {
    NSLog("DB file path: \(Realm.Configuration().fileURL!.absoluteString)")
    do {
      _realmInstance = try Realm()
    } catch (let error as NSError) {
      NSLog("Realm initialization error: \(error)")
    }
  }
  
  fileprivate var _realmInstance: Realm!
  var realmInstance: Realm { get { return _realmInstance! } }
  
  func insertNotes(_ notes: [MNote]) {
    do {
      var savedNotes = [MNote]()
      
      try _realmInstance!.write {
        for note in notes {
          let existedNote = MNote.find(withQuery: "noid == '\(note.noid!)'")
          
          if existedNote != nil {
            // If existed, update
            _realmInstance.add(existedNote!, update: .all)
          } else {
            // Else, add new
            _realmInstance.add(note, update: .error)
          }
          
          savedNotes.append(note)
        }
        
        UserDefaultsHelper.shared.markSavedOnDeviceEverToTrueFor(uid: FirebaseAuth.Auth.auth().currentUser!.uid)
      }
    } catch (let error as NSError) {
      NSLog("Realm saving error: \(error)")
    }
  }
  
  func allNotesRelatedTo(uid: String) -> [MNote] {
    return _allNotesOnDevice().filter { $0.uid! == uid }
  }
  
  private func _allNotesOnDevice() -> [MNote] {
    let results = _realmInstance.objects(MNote.self)
    return [MNote](results)
  }
  
  func clearNotes(multipleNotes notes: [MNote] = [MNote](), singleNote note: MNote? = nil, clearAll: Bool = false) {
    do {
      try _realmInstance.write {
        if !notes.isEmpty {
          _realmInstance.delete(notes)
        }
        
        if note != nil {
          _realmInstance.delete(note!)
        }
        
        if clearAll {
          _realmInstance.deleteAll()
        }
      }
    } catch (let error as NSError) {
      NSLog("Realm saving error: \(error)")
    }
  }
}
