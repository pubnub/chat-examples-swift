//
//  ReachabilityService.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 4/8/19.
//

import SystemConfiguration

class ReachabilityService {
  /// Default `Host` string used by the service
  static var defaultURLString = "https://ps.pndsn.com/time/0"

  /// Defines the various states of network reachability.
  ///
  /// - unknown:      It is unknown whether the network is reachable.
  /// - notReachable: The network is not reachable.
  /// - reachable:    The network is reachable.
  enum NetworkReachabilityStatus {
    /// It is unknown whether the network is reachable.
    case unknown
    /// The network is not reachable.
    case notReachable
    /// The network is reachable.
    case reachable(ConnectionType)
  }

  /// Defines the various connection types detected by reachability flags.
  ///
  /// - ethernetOrWiFi: The connection type is either over Ethernet or WiFi.
  /// - wwan:           The connection type is a WWAN connection.
  enum ConnectionType {
    /// The connection type is either over Ethernet or WiFi.
    case ethernetOrWiFi
    /// The connection type is a WWAN connection.
    case wwan
  }

  /// A closure executed when the network reachability status changes. The closure takes a single argument: the
  /// network reachability status.
  typealias Listener = (NetworkReachabilityStatus) -> Void

  /// Whether the network is currently reachable.
  var isReachable: Bool { return isReachableOnWWAN || isReachableOnEthernetOrWiFi }

  /// Whether the network is currently reachable over the WWAN interface.
  var isReachableOnWWAN: Bool { return networkReachabilityStatus == .reachable(.wwan) }

  /// Whether the network is currently reachable over Ethernet or WiFi interface.
  var isReachableOnEthernetOrWiFi: Bool { return networkReachabilityStatus == .reachable(.ethernetOrWiFi) }

  /// The current network reachability status.
  var networkReachabilityStatus: NetworkReachabilityStatus {
    guard let flags = self.flags else { return .unknown }
    return networkReachabilityStatusForFlags(flags)
  }

  /// The dispatch queue to execute the `listener` closure on.
  var listenerQueue: DispatchQueue = DispatchQueue.main

  /// A closure executed when the network reachability status changes.
  var listener: Listener?

  var flags: SCNetworkReachabilityFlags? {
    var flags = SCNetworkReachabilityFlags()

    if SCNetworkReachabilityGetFlags(reachability, &flags) {
      return flags
    }

    return nil
  }

  private let reachability: SCNetworkReachability
  var previousFlags: SCNetworkReachabilityFlags

  // MARK: - Initialization

  required init?(host: String = defaultURLString) {
    guard let scnReachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }
    self.reachability = scnReachability

    // Set the previous flags to an unreserved value to represent unknown status
    self.previousFlags = SCNetworkReachabilityFlags(rawValue: 1 << 30)
  }

  deinit {
    stop()
  }

  // MARK: - Listening
  /// Starts listening for changes in network reachability status.
  ///
  /// - returns: `true` if listening was started successfully, `false` otherwise.
  @discardableResult
  func start() -> Bool {
    var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
    context.info = Unmanaged.passUnretained(self).toOpaque()

    let callbackEnabled = SCNetworkReachabilitySetCallback(
      reachability, { (_, flags, info) in
        let reachability = Unmanaged<ReachabilityService>.fromOpaque(info!).takeUnretainedValue()
        reachability.notifyListener(flags)
    },
      &context
    )

    let queueEnabled = SCNetworkReachabilitySetDispatchQueue(reachability, listenerQueue)

    listenerQueue.async {
      guard let flags = self.flags else { return }
      self.notifyListener(flags)
    }

    return callbackEnabled && queueEnabled
  }

  /// Stops listening for changes in network reachability status.
  func stop() {
    SCNetworkReachabilitySetCallback(reachability, nil, nil)
    SCNetworkReachabilitySetDispatchQueue(reachability, nil)
  }

  // MARK: - Private - Listener Notification
  private func notifyListener(_ flags: SCNetworkReachabilityFlags) {
    guard previousFlags != flags else { return }
    previousFlags = flags

    listener?(networkReachabilityStatusForFlags(flags))
  }

  // MARK: - Private - Network Reachability Status
  private func networkReachabilityStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkReachabilityStatus {
    guard isNetworkReachable(with: flags) else { return .notReachable }

    var networkStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi)

    if flags.contains(.isWWAN) { networkStatus = .reachable(.wwan) }

    return networkStatus
  }

  private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
    let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)

    return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
  }
}

// MARK: -
extension ReachabilityService.NetworkReachabilityStatus: Equatable {
  /// Returns whether the two network reachability status values are equal.
  ///
  /// - parameter lhs: The left-hand side value to compare.
  /// - parameter rhs: The right-hand side value to compare.
  ///
  /// - returns: `true` if the two values are equal, `false` otherwise.
  static func == (lhs: ReachabilityService.NetworkReachabilityStatus,
                  rhs: ReachabilityService.NetworkReachabilityStatus) -> Bool {
    switch (lhs, rhs) {
    case (.unknown, .unknown):
      return true
    case (.notReachable, .notReachable):
      return true
    case let (.reachable(lhsConnectionType), .reachable(rhsConnectionType)):
      return lhsConnectionType == rhsConnectionType
    default:
      return false
    }
  }
}
