//
//  Models+Displayable.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 5/1/19.
//

import UIKit

protocol Displayable {
  var defaultTextFont: UIFont { get }
  var defaultTextColor: UIColor { get }
  var defaultTextHeight: CGFloat { get }
  var defaultBackgroundColor: UIColor { get }
}

protocol DisplayableTitle: Displayable {
  var title: String { get }
  var titleTextColor: UIColor { get }
  var titleTextHeight: CGFloat { get }
}
protocol DisplayableHeader: Displayable {
  var header: String { get }
  var headerTextColor: UIColor { get }
  var headerTextHeight: CGFloat { get }
}
protocol DisplayableBodyHeader: Displayable {
  var bodyHeader: String { get }
  var bodyHeaderTextColor: UIColor { get }
  var bodyHeaderTextHeight: CGFloat { get }
}
protocol DisplayableBody: Displayable {
  var body: String { get }
  var bodyTextColor: UIColor { get }
  var bodyTextHeight: CGFloat { get }
}
protocol DisplayableBodyFooter: Displayable {
  var bodyFooter: String { get }
  var bodyFooterTextColor: UIColor { get }
  var bodyFooterTextHeight: CGFloat { get }
}
protocol DisplayableFooter: Displayable {
  var footer: String { get }
  var footerTextColor: UIColor { get }
  var footerTextHeight: CGFloat { get }
}

extension Displayable {
  var defaultTextFont: UIFont {
    return .boldSystemFont(ofSize: defaultTextHeight)
  }
  var defaultTextColor: UIColor {
    return .black
  }
  var defaultBackgroundColor: UIColor {
    return .clear
  }
  var defaultTextHeight: CGFloat {
    return 10
  }

  fileprivate func mutableAttributedString(_ text: String,
                                           with font: UIFont, and color: UIColor) -> NSMutableAttributedString {
    let attributes = stringAttributes(with: font, and: color)

    return NSMutableAttributedString(string: text,
                                     attributes: attributes)
  }

  fileprivate func attributedString(_ text: String, with font: UIFont, and color: UIColor) -> NSAttributedString {
    let attributes = stringAttributes(with: font, and: color)

    return NSAttributedString(string: text,
                              attributes: attributes)
  }

  fileprivate func stringAttributes(with font: UIFont, and color: UIColor) -> [NSAttributedString.Key: Any] {
    return [NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color]
  }
}

extension DisplayableTitle {
  var title: String {
    return ""
  }
  var titleTextColor: UIColor {
    return defaultTextColor
  }
  var titleTextHeight: CGFloat {
    return defaultTextHeight
  }

  var attributedTitle: NSAttributedString {
    return attributedString(title,
                            with: defaultTextFont,
                            and: defaultTextColor)
  }
  func attributedTitle(with subtitle: String, using font: UIFont?) -> NSAttributedString {
    let mutableTitle = mutableAttributedString("\(title)\n",
                                               with: defaultTextFont,
                                               and: defaultTextColor)

    let attributes = stringAttributes(with: font ?? defaultTextFont, and: defaultTextColor)
    let subtitle = NSAttributedString(string: subtitle, attributes: attributes)
    mutableTitle.append(subtitle)

    return mutableTitle
  }
}

extension DisplayableHeader {
  var header: String {
    return ""
  }
  var headerTextColor: UIColor {
    return defaultTextColor
  }
  var headerTextHeight: CGFloat {
    return defaultTextHeight
  }
}

extension DisplayableBodyHeader {
  var bodyHeader: String {
    return ""
  }
  var bodyHeaderTextColor: UIColor {
    return defaultTextColor
  }
  var bodyHeaderTextHeight: CGFloat {
    return defaultTextHeight
  }
  var attributedBodyHeader: NSAttributedString {
    return attributedString(bodyHeader,
                            with: defaultTextFont,
                            and: defaultTextColor)
  }
}

extension DisplayableBody {
  var body: String {
    return ""
  }
  var bodyTextColor: UIColor {
    return defaultTextColor
  }
  var bodyTextHeight: CGFloat {
    return defaultTextHeight
  }
  var attributedBody: NSAttributedString {
    return mutableAttributedString(body,
                                   with: defaultTextFont,
                                   and: defaultTextColor)
  }
}

extension DisplayableBodyFooter {
  var bodyFooter: String {
    return ""
  }
  var bodyFooterTextColor: UIColor {
    return defaultTextColor
  }
  var bodyFooterTextHeight: CGFloat {
    return defaultTextHeight
  }
  var attributedBodyFooter: NSAttributedString {
    return mutableAttributedString(bodyFooter,
                                   with: defaultTextFont,
                                   and: defaultTextColor)
  }
}

extension DisplayableFooter {
  var footer: String {
    return ""
  }
  var footerTextColor: UIColor {
    return defaultTextColor
  }
  var footerTextHeight: CGFloat {
    return defaultTextHeight
  }
}

extension DisplayableBodyHeader where Self == Message {
  func attributedBodyHeader(using formatter: DateFormatter) -> NSAttributedString {
    return attributedString(formatter.bodyString(from: self),
                            with: defaultTextFont,
                            and: .gray)
  }
}

extension DisplayableHeader where Self == Message {
  func attributedHeader(using formatter: DateFormatter) -> NSAttributedString {
    return attributedString(formatter.headerString(from: self),
                            with: defaultTextFont,
                            and: .gray)
  }
}

extension ChatRoom: DisplayableTitle, DisplayableBody {
  var defaultTextFont: UIFont {
    return .systemFont(ofSize: defaultTextHeight)
  }
  var defaultTextHeight: CGFloat {
    return 17
  }
  var title: String {
    return name
  }
  var body: String {
    return description ?? ""
  }
}
extension Message: DisplayableHeader, DisplayableBodyHeader {
  var bodyHeaderTextColor: UIColor {
    return .gray
  }
  var defaultBackgroundColor: UIColor {
    if user?.isCurrentUser ?? false {
      return UIColor.messageSender
    }
    return UIColor.messageReceiver
  }
}
extension User: DisplayableBodyHeader, DisplayableBody, DisplayableBodyFooter {
  var bodyHeader: String {
    return displayName
  }
  var body: String {
    return self == User.defaultValue ? "\(displayName) (You)" : displayName
  }
  var bodyFooter: String {
    return designation ?? ""
  }
}
