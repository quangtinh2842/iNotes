//
//  MBase.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 01/04/2026.
//

import ObjectMapper
import RealmSwift
import Firebase

class MBase: Object, Mappable {
  override class func shouldIncludeInDefaultSchema() -> Bool {
    return false
  }
  
  class func collectionName() -> String {
    fatalError("This method must be overridden")
  }
  
  override class func primaryKey() -> String? {
    return nil
//    fatalError("This method must be overridden")
  }
  
  class func mapObject(jsonObject: NSDictionary) -> MBase? {
    fatalError("This method must be overridden")
  }
  
  override init() {}
  
  required init?(map: ObjectMapper.Map) {
  }
  
  func mapping(map: ObjectMapper.Map) {
    fatalError("This method must be overridden")
  }
  
  func validate() -> (ModelValidationError, String?) {
    fatalError("This method must be overridden")
  }
  
  // Read
  class func find(byId objectId: String, completion handler: @escaping ObjectQueryResultHandler) {
    let dbRef = Database.database().reference()
    let collectionName = self.collectionName()
    
    let query = dbRef.child("\(collectionName)/\(objectId)")
    
    query.observe(.value, with: { (snapshot) in
      if !(snapshot.value is NSDictionary) {
        handler(nil, NotFoundError)
        return
      }
      
      let resultDict = snapshot.value as! NSDictionary
      let resultModel = self.mapObject(jsonObject: resultDict)
      handler(resultModel, nil)
    }) { (error) in
      handler(nil, error)
    }
  }
  
  class func query(withClause queryClause: [QueryClausesEnum: AnyObject]? = nil,
                   completion handler: @escaping CollectionQueryResultHandler) {
    let dbRef = Database.database().reference()
    let collectionName = self.collectionName()
    
    var query = dbRef.child(collectionName) as DatabaseQuery
    
    if queryClause != nil {
      if let orderedChildKey = queryClause![.OrderedChildKey] {
        query = query.queryOrdered(byChild: orderedChildKey as! String)
      }
      
      if let startValue = queryClause![.StartValue] {
        query = query.queryStarting(atValue: startValue)
      }
      
      if let endValue = queryClause![.EndValue] {
        query = query.queryEnding(atValue: endValue)
      }
      
      if let exactValue = queryClause![.ExactValue] {
        query = query.queryEqual(toValue: exactValue)
      }
    }
    
    query.observeSingleEvent(of: .value, with: { snapshot in
      if !(snapshot.value is NSDictionary) {
        handler([], NotFoundError)
        return
      }
      
      var resultModels: [MBase] = []
      let results = snapshot.value as! [String: NSDictionary]
      
      for (_, resultDict) in results {
        let resultModel = self.mapObject(jsonObject: resultDict)
        
        if resultModel != nil {
          resultModels.append(resultModel!)
        }
      }
      
      handler(resultModels, nil)
    }) { (error) in
      handler([], error)
    }
  }
  
  func toDict() -> [String: Any] {
    fatalError("This method must be overridden")
  }
  
  // Write
  func save(completion handler: UpdateValueHandler? = nil) throws -> String {
    let (validation, errors) = self.validate()
    let errorDomain = "Model validation failed"
    
    switch validation {
    case .Valid: break
    case .InvalidId:
      throw NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "IDs \(errors!) must not be blank"])
    case .InvalidTimestamp:
      throw NSError(domain: errorDomain, code: -2, userInfo: [NSLocalizedDescriptionKey: "Timestamps \(errors!) must not be blank"])
    case .InvalidBlankAttribute:
      throw NSError(domain: errorDomain, code: -3, userInfo: [NSLocalizedDescriptionKey: "Attributes \(errors!) must not be blank"])
    }
    
    let dbRef = Database.database().reference()
    let collectionName = type(of: self).collectionName()
    let primaryKey = type(of: self).primaryKey()!
    
    var objectId = ""
    
    if let primaryKeyValue = self.value(forKey: primaryKey) {
      objectId = self._saveAsUpdate(inDb: dbRef, inCollection: collectionName, withId: primaryKeyValue as! String, completion: handler)
    } else {
      objectId = self._saveAsNew(inDb: dbRef, inCollection: collectionName, withPrimaryKey: primaryKey, completion: handler)
    }
    
    return objectId
  }
  
  func _saveAsUpdate(inDb dbRef: DatabaseReference, inCollection colName: String, withId objectId: String, completion handler: UpdateValueHandler?) -> String {
    
    let objectJson = self.toDict()
    
    let updatesManifest = ["/\(colName)/\(objectId)": objectJson]
    
    if handler != nil {
      dbRef.updateChildValues(updatesManifest, withCompletionBlock: handler!)
    } else {
      dbRef.updateChildValues(updatesManifest)
    }
    
    return objectId
  }
  
  private func _saveAsNew(inDb dbRef: DatabaseReference, inCollection colName: String, withPrimaryKey primaryKey: String, completion handler: UpdateValueHandler?) -> String {
    let objectId = dbRef.child(colName).childByAutoId().key!
    
    var objectJson = self.toDict()
    objectJson[primaryKey] = objectId
    
    let updatesManifest = ["/\(colName)/\(objectId)": objectJson]
    
    if handler != nil {
      dbRef.updateChildValues(updatesManifest, withCompletionBlock: handler!)
    } else {
      dbRef.updateChildValues(updatesManifest)
    }
    
    return objectId
  }
}
