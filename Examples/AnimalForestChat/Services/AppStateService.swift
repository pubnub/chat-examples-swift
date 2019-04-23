//
//  AppStateService.swift
//  RCDemo
//
//  Created by Craig Lane on 4/8/19.
//

import UIKit
import NotificationCenter

class AppStateService {

  var didBecomeActiveToken: NSObjectProtocol?
  var willResignActiveToken: NSObjectProtocol?
  var didEnterBackgroundToken: NSObjectProtocol?
  var willEnterForegroundToken: NSObjectProtocol?

  enum AppStates {
    case didBecomeActive
    case willResignActive
    case didEnterBackground
    case willEnterForeground
  }

  typealias Listener = (AppStates) -> Void

  func start(listener: Listener?) {
    // Start observering
    if didBecomeActiveToken == nil {
      didBecomeActiveToken = NotificationCenter.default
        .addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (_) in
        listener?(.didBecomeActive)
      }
    }

    if willResignActiveToken == nil {
      willResignActiveToken = NotificationCenter
        .default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (_) in
        listener?(.willResignActive)
      }
    }

    if didEnterBackgroundToken == nil {
      didEnterBackgroundToken = NotificationCenter.default
        .addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (_) in
        listener?(.didEnterBackground)
      }
    }

    if willEnterForegroundToken == nil {
      willEnterForegroundToken = NotificationCenter.default
        .addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { (_) in
        listener?(.willEnterForeground)
      }
    }
  }

  deinit {
    stop()
  }

  func stop() {
    // Stop observing
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
