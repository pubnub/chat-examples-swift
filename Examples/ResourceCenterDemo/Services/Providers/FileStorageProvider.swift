//
//  FileStorageProvider.swift
//  RCDemo
//
//  Created by Craig Lane on 4/15/19.
//

import Foundation

public struct FileStorageProvider {

  fileprivate init() { }

  enum Directory {
    // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application,
    // should be stored in <Application_Home>/Documents and will be automatically backed up by iCloud.
    case documents

    // Data that can be downloaded again or regenerated should be stored in <Application_Home>/Library/Caches.
    // Examples of files you should put in the Caches directory include database cache files and downloadable content,
    // such as that used by magazine, newspaper, and map applications.
    case caches
  }

  /// Returns URL constructed from specified directory
  static fileprivate func getURL(for directory: Directory) -> URL? {
    var searchPathDirectory: FileManager.SearchPathDirectory

    switch directory {
    case .documents:
      searchPathDirectory = .documentDirectory
    case .caches:
      searchPathDirectory = .cachesDirectory
    }

    if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
      return url
    } else {
      NSLog("Could not create URL at directory: \(searchPathDirectory)")
      return nil
    }
  }

  /// Store an encodable struct to the specified directory on disk
  ///
  /// - Parameters:
  ///   - object: the encodable struct to store
  ///   - directory: where to store the struct
  ///   - fileName: what to name the file where the struct data will be stored
  @discardableResult
  static func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) -> Bool {
    guard let url = getURL(for: directory) else {
      return false
    }

    let appendedURL = url.appendingPathComponent(fileName, isDirectory: false)

    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(object)
      if FileManager.default.fileExists(atPath: appendedURL.path) {
        try FileManager.default.removeItem(at: appendedURL)
      }
      FileManager.default.createFile(atPath: appendedURL.path, contents: data, attributes: nil)
    } catch {
      NSLog("Error storing data: \(error.localizedDescription)")
      return false
    }

    return true
  }

  /// Retrieve and convert a struct from a file on disk
  ///
  /// - Parameters:
  ///   - fileName: name of the file where struct data is stored
  ///   - directory: directory where struct data is stored
  ///   - type: struct type (i.e. Message.self)
  /// - Returns: decoded struct model(s) of data
  static func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T? {
    guard let url = getURL(for: directory) else {
      return nil
    }

    let appendedURL = url.appendingPathComponent(fileName, isDirectory: false)

    if !FileManager.default.fileExists(atPath: url.path) {
      NSLog("File at path \(appendedURL.path) does not exist!")
      return nil
    }

    if let data = FileManager.default.contents(atPath: appendedURL.path) {
      let decoder = JSONDecoder()
      do {
        let model = try decoder.decode(type, from: data)
        return model
      } catch {
        NSLog("Error reading data: \(error.localizedDescription)")
        return nil
      }
    } else {
      NSLog("No data at \(appendedURL.path)")
      return nil
    }
  }

  /// Remove all files at specified directory
  @discardableResult
  static func clear(_ directory: Directory) -> Bool {
    guard let url = getURL(for: directory) else {
      return false
    }

    do {
      let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
      for fileUrl in contents {
        try FileManager.default.removeItem(at: fileUrl)
      }
    } catch {
      NSLog("Error clearing all stored data: \(error.localizedDescription)")
      return false
    }

    return true
  }

  /// Remove specified file from specified directory
  @discardableResult
  static func remove(_ fileName: String, from directory: Directory) -> Bool {
    guard let url = getURL(for: directory) else {
      return false
    }

    let appendedURL = url.appendingPathComponent(fileName, isDirectory: false)

    if FileManager.default.fileExists(atPath: appendedURL.path) {
      do {
        try FileManager.default.removeItem(at: appendedURL)
      } catch {
        NSLog("Error removing stored data: \(error.localizedDescription)")
        return false
      }
    }

    return true
  }

  /// Returns BOOL indicating whether file exists at specified directory with specified file name
  static func fileExists(_ fileName: String, in directory: Directory) -> Bool {
    guard let url = getURL(for: directory) else {
      return false
    }

    let appendedURL = url.appendingPathComponent(fileName, isDirectory: false)

    return FileManager.default.fileExists(atPath: appendedURL.path)
  }
}
