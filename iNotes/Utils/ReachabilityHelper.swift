//
//  ReachabilityHelper.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 05/04/2026.
//

import Foundation
import Reachability

typealias ReachabilityStatusChangedHandler = (Bool) -> ()

class ReachabilityHelper {
  static let shared = ReachabilityHelper()
  
  private init() {}
  
  fileprivate var _reachability: Reachability? = nil
  
  func setupReachability(withHandler handler: @escaping ReachabilityStatusChangedHandler) {
    do {
      _reachability = try! Reachability()
      
      let statusHandler: ((Reachability) -> ()) = { handler($0.connection != .unavailable) }
      _reachability?.whenReachable = statusHandler
      _reachability?.whenUnreachable = statusHandler
      
      try _reachability!.startNotifier()
    } catch (let error as NSError) {
      print(error)
    }
  }
  
  func isConnected() -> Bool {
    _reachability?.connection != .unavailable
  }
}
