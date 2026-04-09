//
//  MUser.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 02/04/2026.
//

import Foundation
import ObjectMapper
import FirebaseAuth
import RealmSwift

class MUser: MBase {
  override class func shouldIncludeInDefaultSchema() -> Bool {
    return true
  }
  
  @Persisted(primaryKey: true) var uid: String?
  @Persisted var providerID: String?
  @Persisted var displayName: String?
  @Persisted var email: String?
  @Persisted var photoURL: String?
  
  override class func collectionName() -> String {
    return "synced_users"
  }
  
  override class func primaryKey() -> String? {
    return "uid"
  }
  
  override class func mapObject(jsonObject: NSDictionary) -> MBase? {
    return Mapper<MUser>().map(JSONObject: jsonObject)
  }
  
  override init() { super.init() }
  
  required init?(map: ObjectMapper.Map) {
    super.init(map: map)
    
    let attributes = ["uid", "providerID", "displayName", "email", "photoURL"]
    let validations = attributes.map {
      map[$0].currentValue != nil
    }.reduce(true) { $0 && $1 }
    
    if !validations {
      return nil
    }
  }
  
  init(authUser: FirebaseAuth.User) {
    super.init()
    
    self.uid = authUser.uid
    self.providerID = authUser.providerID
    self.displayName = authUser.displayName
    self.email = authUser.email
    self.photoURL = authUser.photoURL?.absoluteString ?? ""
  }
  
  init(mUser: MUser) {
    super.init()
    
    self.uid = mUser.uid
    self.providerID = mUser.providerID
    self.displayName = mUser.displayName
    self.email = mUser.email
    self.photoURL = mUser.photoURL
  }
  
  override func mapping(map: ObjectMapper.Map) {
    uid         <- map["uid"]
    providerID  <- map["providerID"]
    displayName <- map["displayName"]
    email       <- map["email"]
    photoURL    <- map["photoURL"]
  }
  
  static func getCurrentUser() -> MUser? {
    if let authUser = Auth.auth().currentUser {
      let mUser = MUser(authUser: authUser)
      return mUser
    } else {
      return nil
    }
  }
  
  static func signOutEverywhere() throws {
    try Auth.auth().signOut()
  }
  
  override func validate() -> (ModelValidationError, String?) {
    if self.uid == nil || self.uid!.isEmpty ||
        self.providerID == nil || self.providerID!.isEmpty {
      return (.InvalidId, "uid, providerID")
    }
    
    return (.Valid, nil)
  }
  
  override func toDict() -> [String: Any] {
    let tmp = MUser(mUser: self)
    return tmp.toJSON()
  }
}
