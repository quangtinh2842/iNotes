//
//  CommonTypes.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 02/04/2026.
//

import Foundation
import Firebase

typealias ObjectQueryResultHandler = (_ result: MBase?, _ error: Error?) -> ()
typealias CollectionQueryResultHandler = (_ results: [MBase], _ error: Error?) -> ()
typealias StatusReturnHandler = (_ status: Bool, _ error: Error?) -> ()
typealias ErrorHandler = (Error?) -> ()
typealias UpdateValueHandler = (Error?, DatabaseReference) -> ()

let NotFoundError: NSError = {
  return NSError(domain: "Not found", code: -1002, userInfo: [NSLocalizedDescriptionKey: "Result(s) not found"])
}()

enum QueryClausesEnum: String {
  case OrderedChildKey = "OrderedChildKey"
  case StartValue = "StartValue"
  case EndValue = "EndValue"
  case ExactValue = "ExactValue"
}

enum ModelValidationError: Error {
  case Valid
  case InvalidId
  case InvalidTimestamp
  case InvalidBlankAttribute
}

func processAfterSignIn(completion handler: @escaping (Error?) -> Void) {
  HomeViewObserver.shared = HomeViewObserver()
  
  if ReachabilityHelper.shared.isConnected() {
    HomeViewObserver.shared.syncForFirebaseIfHasNoSyncedYet()
  }
  
  handler(nil)
}
