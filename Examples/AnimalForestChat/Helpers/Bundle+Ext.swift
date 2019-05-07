//
//  Bundle+Ext.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/10/19.
//

import Foundation

// tag::KEYS-1[]
// Bundle+Ext.swift
extension Bundle {
  func pubSubKeys(for key: String) -> (pubKey: String, subKey: String) {
    // Ensure that the keys exist
    guard let dict = self.object(forInfoDictionaryKey: key) as? [String: String],
          let pubKey = dict["PubKey"], !pubKey.isEmpty,
          let subKey = dict["SubKey"], !subKey.isEmpty else {
      NSLog("Please verify that your pub/sub keys are set inside the AnimalForestChat.<CONFIG>.xcconfig files.")

      // This will only crash on debug configurations
      assertionFailure("Please ensure that your Pub/Sub keys are set inside the AnimalForestChat.xcconfig files")

      return ("", "")
    }

    return (pubKey, subKey)
  }
}
// end::KEYS-1[]
