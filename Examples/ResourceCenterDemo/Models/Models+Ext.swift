//
//  Models+Ext.swift
//  RCDemo
//
//  Created by Craig Lane on 4/11/19.
//

import Foundation

protocol BaseConvertibleType {
  associatedtype BaseType

  var baseValue: BaseType? { get }
}

enum StorableTarget {
  case userDefaults
  case diskCache
  case disk
}

protocol Storable {
  associatedtype Element

  static var storedValues: [Element] { get }
}

extension Storable {
  static func firstStored(with predicate: (Element) -> Bool) -> Element? {
    return storedValues.first(where: predicate)
  }

  static func fetchStored(with predicate: (Element) -> Bool) -> [Element]? {
    return storedValues.filter(predicate)
  }
}

extension Encodable {
  func store(in location: StorableTarget, at name: String) {
    switch location {
    case .userDefaults:
      let encodedSelf = try? JSONEncoder().encode(self)
      UserDefaults.standard.set(encodedSelf, forKey: name)
    case .diskCache:
      FileStorageProvider.store(self, to: .caches, as: name)
    case .disk:
      FileStorageProvider.store(self, to: .documents, as: name)
    }
  }
}

extension Decodable {
  static func retrieve(from location: StorableTarget, with name: String) -> Self? {
    switch location {
    case .userDefaults:
      guard let storedData = UserDefaults.standard.data(forKey: name) else {
        return nil
      }
      return try? JSONDecoder().decode(Self.self, from: storedData)
    case .diskCache:
      return FileStorageProvider.retrieve(name, from: .caches, as: Self.self)
    case .disk:
      return FileStorageProvider.retrieve(name, from: .documents, as: Self.self)
    }
  }
}
