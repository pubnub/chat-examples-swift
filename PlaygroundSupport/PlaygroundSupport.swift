//
//  PlaygroundSupport.swift
//  PlaygroundSupport
//
//  Created by Craig Lane on 3/13/19.
//

import Foundation

// Mock PlaygroundSupport import for non-Playground sources
public class PlaygroundPage {
  public static var current = PlaygroundPage()

  public var needsIndefiniteExecution = false
  public func finishExecution() {}
}
