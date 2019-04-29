//
//  AppStateService.swift
//  RCDemo
//
//  Created by Craig Lane on 4/8/19.
//

import UIKit
import NotificationCenter

class AppStateService {
  /// Token returned from observing the `UIApplication.didBecomeActiveNotification`
  var didBecomeActiveToken: NSObjectProtocol?
  /// Token returned from observing the `UIApplication.willResignActiveNotification`
  var willResignActiveToken: NSObjectProtocol?
  /// Token returned from observing the `UIApplication.didEnterBackgroundNotification`
  var didEnterBackgroundToken: NSObjectProtocol?
  /// Token returned from observing the `UIApplication.willEnterForegroundNotification`
  var willEnterForegroundToken: NSObjectProtocol?

  /// Defines the various states of network reachability.
  ///
  /// - didBecomeActive:      Application state did become `Active`
  /// - willResignActive:     Application state will become `Inactive`
  /// - didEnterBackground:   Application did enter the background
  /// - willEnterForeground:  Application will enter the foreground
  enum StateChange {
    /// Application state did become `Active`
    case didBecomeActive
    /// Application state will become `Inactive`
    case willResignActive
    /// Application did enter the background
    case didEnterBackground
    /// Application will enter the foreground
    case willEnterForeground
  }

  /// A closure executed when the application's state changes. The closure takes a single argument: the
  /// app state status.
  typealias Listener = (StateChange) -> Void

  /// A closure executed when the app state status changes.
  var listener: Listener?

  /// Starts listening for changes in app stats.
  func start() {
    if didBecomeActiveToken == nil {
      didBecomeActiveToken = NotificationCenter.default
        .addObserver(forName: UIApplication.didBecomeActiveNotification,
                     object: nil, queue: nil) { [weak self] (_) in
          self?.listener?(.didBecomeActive)
      }
    }

    if willResignActiveToken == nil {
      willResignActiveToken = NotificationCenter.default
        .addObserver(forName: UIApplication.willResignActiveNotification,
                     object: nil, queue: nil) { [weak self]  (_) in
        self?.listener?(.willResignActive)
      }
    }

    if didEnterBackgroundToken == nil {
      didEnterBackgroundToken = NotificationCenter.default
        .addObserver(forName: UIApplication.didEnterBackgroundNotification,
                     object: nil,
                     queue: nil) { [weak self]  (_) in
        self?.listener?(.didEnterBackground)
      }
    }

    if willEnterForegroundToken == nil {
      willEnterForegroundToken = NotificationCenter.default
        .addObserver(forName: UIApplication.willEnterForegroundNotification,
                     object: nil, queue: nil) { [weak self]  (_) in
        self?.listener?(.willEnterForeground)
      }
    }
  }

  deinit {
    stop()
  }

  /// Stops listening for changes in app state.
  func stop() {
    if let didBecomeActive = didBecomeActiveToken {
      NotificationCenter.default.removeObserver(didBecomeActive)
    }
    if let willResignActive = willResignActiveToken {
      NotificationCenter.default.removeObserver(willResignActive)
    }
    if let didEnterBackground = didEnterBackgroundToken {
      NotificationCenter.default.removeObserver(didEnterBackground)
    }
    if let willEnterForeground = willEnterForegroundToken {
      NotificationCenter.default.removeObserver(willEnterForeground)
    }
  }
}
