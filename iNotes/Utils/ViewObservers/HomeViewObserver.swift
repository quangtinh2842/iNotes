import Foundation
import SwiftUI
import FirebaseAuth
import RealmSwift

class HomeViewObserver: NSObject, ObservableObject {
  @Published var notes: [MNote] = []
  
  static var shared = HomeViewObserver()
  
  override init() {
    super.init()
    let uid = Auth.auth().currentUser!.uid
    
    if UserDefaultsHelper.shared.hasSavedOnDeviceEverFor(uid: uid) {
      self.notes = RealmManager.sharedManager.allNotesRelatedTo(uid: uid)
    } else {
      FirebaseManager.shared.allNotesRelatedTo(uid: uid) { error, result in
        for note in result {
          note.wasSynced = true
        }
        
        RealmManager.sharedManager.insertNotes(result)
        self.notes = result
      }
    }
  }
  
  func syncForFirebaseIfHasNoSyncedYet() {
    var shouldSync = false
    
    for note in self.notes {
      if note.wasSynced == false {
        shouldSync = true
        break
      }
    }
    
    if shouldSync {
      syncForFirebase()
    } else {
      HomeViewObserver.shared.deleteSpareNotesOnFirebase()
    }
  }
  
  func syncForNotesNoSync(completion handler: @escaping (Error?) -> Void) {
    let group = DispatchGroup()
    var lastError: Error?
    
    for (i, _) in self.notes.enumerated() {
      if self.notes[i].wasSynced == false {
        group.enter()
        let _ = try! self.notes[i].save { error, _ in
          if error != nil {
            lastError = error
            group.leave()
          } else {
            try! RealmManager.sharedManager.realmInstance.write {
              self.notes[i].wasSynced = true
              let tmp = self.notes
              self.notes = []
              self.notes = tmp
              group.leave()
            }
          }
        }
      }
    }
    
    group.notify(queue: .main) {
      handler(lastError)
    }
  }
  
  func syncForFirebase() {
    syncForNotesNoSync { _ in
      HomeViewObserver.shared.deleteSpareNotesOnFirebase()
    }
  }
  
  func deleteSpareNotesOnFirebase() {
    let idsOfNotesOnDevice = Set(self.notes.map { $0.noid! })
    let uid = Auth.auth().currentUser!.uid
    FirebaseManager.shared.allNotesRelatedTo(uid: uid) { _, result in
      let idsOfNotesOnFirebase = Set(result.map { $0.noid! })
      let idsToRemove = idsOfNotesOnFirebase.subtracting(idsOfNotesOnDevice)
      
      FirebaseManager.shared.deleteNotes(noteIds: Array<String>(idsToRemove)) { error2 in
      }
    }
  }
  
  func updateNoteForAll(_ note: MNote) {
    let noidArray = notes.map { $0.noid! }
    
    if noidArray.contains(note.noid!) {
      for (i, _) in notes.enumerated() {
        if notes[i].noid == note.noid {
          _saveOnlineAndOffline(note: note) { [self] in
            self.notes[i] = note
          }
        }
      }
    } else {
      _saveOnlineAndOffline(note: note) { [self] in
        self.notes.append(note)
      }
    }
  }
  
  private func _saveOnlineAndOffline(note: MNote, completion handler: @escaping () -> Void) {
    let group = DispatchGroup()
    
    if ReachabilityHelper.shared.isConnected() {
      group.enter()
      let _ = try! note.save { error, _ in
        try! RealmManager.sharedManager.realmInstance.write {
          
          if error != nil {
            note.wasSynced = false
          } else {
            note.wasSynced = true
          }
          
          group.leave()
        }
      }
    } else {
      group.enter()
      try! RealmManager.sharedManager.realmInstance.write {
        note.wasSynced = false
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
//      if note.realm == nil {
//        RealmManager.sharedManager.insertNotes([note])
//      }
      
      RealmManager.sharedManager.insertNotes([note])
      handler()
    }
  }
  
  func deleteOneNote(at offsets: IndexSet) {
    for index in offsets {
      let note = self.notes[index]
      let noteId = note.noid!
      
      if note.realm != nil {
        if !note.isInvalidated {
          self.notes.remove(at: index)
          RealmManager.sharedManager.clearNotes(singleNote: note)
          MNote.deleteWithId(noteId) { _ in }
        }
      }
    }
  }
}
