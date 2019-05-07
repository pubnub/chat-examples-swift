//
//  PubNub+Ext.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 3/14/19.
//

import PubNub

extension Date {
  /// 15-digit precision unix time (UTC) since 1970
  ///
  /// - note: A 64-bit `Double` has a max precision of 15-digits, so
  ///         any value derived from a `TimeInterval` will not be precise
  ///         enough to rely on when querying system APIs which use
  ///         17-digit precision UTC values
  var timeIntervalAsImpreciseToken: Int64 {
    return Int64(self.timeIntervalSince1970 * 10000000)
  }
}

extension Message {
  var timeToken: NSNumber {
    return NSNumber(value: sentAt)
  }
}

extension PNStatus {
  var error: NSError? {
    guard let errorStatus = self as? PNErrorStatus, errorStatus.isError else {
      return nil
    }

    return NSError(domain: "\(self.stringifiedOperation()) \(self.stringifiedCategory())",
            code: statusCode,
            userInfo: [
              NSLocalizedDescriptionKey: "\(self)",
              NSLocalizedFailureReasonErrorKey: errorStatus.errorData.information
            ])
  }
}

// tag::INIT-1[]
// PubNub+Ext.swift
extension PubNub {
  static func configure(with userId: String? = User.defaultValue.uuid, using bundle: Bundle = Bundle.main) -> PubNub {
    // Read Pub/Sub Keys from Info.plist
    let (pubKey, subKey) = bundle.pubSubKeys(for: "PubNub")

    let config = PNConfiguration(publishKey: pubKey, subscribeKey: subKey)
    if let uuid = userId {
      NSLog("Configuring PubNub with \(uuid)")
      config.uuid = uuid
    }

    // Gets rid of deprecation warning
    config.stripMobilePayload = false

    return PubNub.clientWithConfiguration(config)
  }
}
// end::INIT-1[]
