//
//  MNote.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 01/04/2026.
//

import RealmSwift
import Foundation
import ObjectMapper
import Firebase

class MNote: MBase, Identifiable {
  override class func shouldIncludeInDefaultSchema() -> Bool {
    return true
  }
  
  @Persisted(primaryKey: true) var noid: String?
  @Persisted var uid: String?
  @Persisted var content: String = ""
  @Persisted var createdTime: Date?
  @Persisted var changedTime: Date?
  @Persisted var wasSynced: Bool = false
  
  override class func collectionName() -> String {
    return "notes"
  }
  
  override class func primaryKey() -> String? {
    return "noid"
  }
  
  override class func mapObject(jsonObject: NSDictionary) -> MBase? {
    return Mapper<MNote>().map(JSONObject: jsonObject)
  }
  
  override init() { super.init() }
  
  init(noid: String, uid: String, content: String, createdTime: Date, changedTime: Date, wasSynced: Bool) {
    super.init()
    
    self.noid = noid
    self.uid = uid
    self.content = content
    self.createdTime = createdTime
    self.changedTime = changedTime
    self.wasSynced = wasSynced
  }
  
  init(mNote: MNote) {
    super.init()
    
    self.noid = mNote.noid
    self.uid = mNote.uid
    self.content = mNote.content
    self.createdTime = mNote.createdTime
    self.changedTime = mNote.changedTime
    self.wasSynced = mNote.wasSynced
  }
  
  required init?(map: ObjectMapper.Map) {
    super.init(map: map)
    
    let attributes = ["noid", "uid", "content", "createdTime", "changedTime"]
    let validations = attributes.map {
      map[$0].currentValue != nil
    }.reduce(true) { $0 && $1 }
    
    if !validations {
      return nil
    }
  }
  
  override func mapping(map: ObjectMapper.Map) {
    noid          <- map["noid"]
    uid           <- map["uid"]
    content       <- map["content"]
    createdTime   <- (map["createdTime"], DateTransform())
    changedTime   <- (map["changedTime"], DateTransform())
    wasSynced     <- map["wasSynced"]
  }
  
  static func getAutoId() -> String {
    let ref = Database.database().reference().child(MNote.collectionName()).childByAutoId()
    let autoID = ref.key
    return autoID!
  }
  
  override func validate() -> (ModelValidationError, String?) {
    if self.noid == nil || self.noid!.isEmpty ||
        self.uid == nil || self.uid!.isEmpty {
      return (.InvalidId, "noid, uid")
    }
    
    if self.content.isEmpty {
      return (.InvalidBlankAttribute, "content")
    }
    
    if self.createdTime == nil || self.changedTime == nil {
      return (.InvalidTimestamp, "createdTime, changedTime")
    }
    
    return (.Valid, nil)
  }
  
  class func find(withQuery queryString: String?) -> MNote? {
    let realm = RealmManager.sharedManager.realmInstance
    var results = realm.objects(MNote.self)
    
    if queryString != nil {
      results = results.filter(queryString!)
    }
    
    return results.first
  }
  
  override func toDict() -> [String: Any] {
    let tmp = MNote(mNote: self)
    return tmp.toJSON()
  }
}
