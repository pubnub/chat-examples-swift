//
//  DateFormatter+Message.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 5/2/19.
//

import Foundation

extension DateFormatter {
  func bodyString(from message: Message) -> String {
    doesRelativeDateFormatting = false
    dateFormat = "h:mm a"

    return string(from: message.sentDate)
  }

  func headerString(from message: Message) -> String {
    switch true {
    case Calendar.current.isDateInToday(message.sentDate) || Calendar.current.isDateInYesterday(message.sentDate):
      doesRelativeDateFormatting = true
      dateStyle = .short
      timeStyle = .short
    case Calendar.current.isDate(message.sentDate, equalTo: Date(), toGranularity: .weekOfYear):
      dateFormat = "EEEE h:mm a"
    case Calendar.current.isDate(message.sentDate, equalTo: Date(), toGranularity: .year):
      dateFormat = "E, d MMM, h:mm a"
    default:
      dateFormat = "MMM d, yyyy, h:mm a"
    }

    return string(from: message.sentDate)
  }
}
