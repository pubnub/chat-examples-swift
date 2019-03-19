import PubNub

public extension PubNub {
  static func date(fromTimetoken token: NSNumber) -> Date {
    return Date(timeIntervalSince1970: TimeInterval(floatLiteral: token.doubleValue * 0.0000001))
  }
}

#if swift(>=5.0)
public extension String.StringInterpolation {
  mutating func appendInterpolation(_ message: PNMessageResult) {
    appendInterpolation([
      "\"\(message.data.message ?? "")\" ",
      "on \(message.data.channel) channel ",
      "at \(PubNub.date(fromTimetoken: message.data.timetoken))"].reduce("", +)
    )
  }

  mutating func appendInterpolation(_ data: PNPresenceEventData) {
    if data.presenceEvent != "state-change" {
      appendInterpolation([
        "\(data.presence.uuid ?? "") \"\(data.presenceEvent)'ed\" ",
        "at: \(PubNub.date(fromTimetoken: data.presence.timetoken)) ",
        "on \(data.channel) (Occupancy: \(data.presence.occupancy))"].reduce("", +)
      )
    } else {
      appendInterpolation([
        "\(data.presence.uuid ?? "") changed state ",
        "at: \(PubNub.date(fromTimetoken: data.presence.timetoken)) ",
        "on \(data.channel) ",
        "to: \(data.presence.state ?? [:])"].reduce("", +)
      )
    }
  }

  // swiftlint:disable superfluous_disable_command cyclomatic_complexity function_body_length
  mutating func appendInterpolation(_ status: PNStatus) {
    switch status.category {
    case .PNUnknownCategory:
      appendInterpolation("Status Unknown")
    case .PNAcknowledgmentCategory:
      appendInterpolation("Status Acknowledgement")
    case .PNAccessDeniedCategory:
      appendInterpolation("PAM Error: for resource Will Auto Retry?: \(status.willAutomaticallyRetry ? "Yes" : "No")")
    case .PNTimeoutCategory:
      appendInterpolation("Error: Request timed out. Temporary connectivity issues, etc.")
    case .PNNetworkIssuesCategory:
      appendInterpolation("Error: Request can't be processed because of network issues.")
    case .PNRequestMessageCountExceededCategory:
      appendInterpolation("Message Count Exceeded")
    case .PNConnectedCategory:
      appendInterpolation("Connected, Channel Info: \((status as? PNSubscribeStatus)?.subscribedChannels ?? [])")
    case .PNReconnectedCategory:
      appendInterpolation("Reconnected, Channel Info: \((status as? PNSubscribeStatus)?.subscribedChannels ?? [])")
    case .PNDisconnectedCategory:
      if status.operation == PNOperationType.unsubscribeOperation {
        appendInterpolation("Expected Disconnect")
      } else {
        appendInterpolation("Error: Unexpected Disconnect")
      }
    case .PNUnexpectedDisconnectCategory:
      appendInterpolation(
        "Unexpected Disconnect, Channel Info: \((status as? PNSubscribeStatus)?.subscribedChannels ?? [])")
    case .PNCancelledCategory:
      appendInterpolation("Request Cancelled")
    case .PNBadRequestCategory:
      appendInterpolation("Bad Reques")
    case .PNRequestURITooLongCategory:
      appendInterpolation("Request-URI Took Too Long")
    case .PNMalformedFilterExpressionCategory:
      appendInterpolation("Malformed Filter Expression")
    case .PNMalformedResponseCategory:
      appendInterpolation("Malformed Response")
    case .PNDecryptionErrorCategory:
      appendInterpolation("Decryption Error")
    case .PNTLSConnectionFailedCategory:
      appendInterpolation("TLS Connection Failed")
    case .PNTLSUntrustedCertificateCategory:
      appendInterpolation("Untrusted TLS Certificate")
    @unknown default:
      appendInterpolation("Unknown Status with code: \(status.category.rawValue)")
    }
  }
}
#endif
