import DesignSystem
import Foundation
import SecurityDashboard
import SwiftUI

protocol UnresolvedAlertShowable {
  func generateMessage() -> AttributedString
  func generateActionableMessage() -> UnresolvedAlertActionableMessage?
  func generatePostActionableMessage() -> AttributedString?
}

extension UnresolvedAlertShowable {
  func generateActionableMessage() -> UnresolvedAlertActionableMessage? { return nil }
  func generatePostActionableMessage() -> AttributedString? { return nil }
}

public protocol UnresolvedAlertActionableMessage {
  var state: DataLeakPlaintextTrayAlert.Actionable.State { get }
  var message: AttributedString { get }
  var icon: Image { get }
  func action()
}

public struct UnresolvedAlert {

  let alert: TrayAlertProtocol
  let title: AttributedString?
  let message: AttributedString
  let actionableMessage: UnresolvedAlertActionableMessage?
  let postActionableMessage: AttributedString?

  init(_ trayAlert: TrayAlertProtocol) {
    self.alert = trayAlert
    self.title = UnresolvedAlert.generateTitle(from: trayAlert)

    guard let showableAlert = trayAlert as? UnresolvedAlertShowable else {
      fatalError("Unhandled alert")
    }

    self.message = showableAlert.generateMessage()
    self.actionableMessage = showableAlert.generateActionableMessage()
    self.postActionableMessage = showableAlert.generatePostActionableMessage()
  }

  private static func generateTitle(from alert: TrayAlertProtocol) -> AttributedString? {
    var titleString = ""

    if let timestamp = alert.timestamp {
      titleString.append(NSLocalizedString(timestamp, comment: ""))
    }

    titleString += "\n\(alert.title)"

    var attributedString = AttributedString(titleString)

    guard let rangeOfBreachName = attributedString.range(of: alert.title) else {
      return nil
    }

    attributedString[rangeOfBreachName].setAttributes(.semibold)

    return attributedString
  }
}

extension DashlaneSixTrayAlert: UnresolvedAlertShowable {
  func generateMessage() -> AttributedString {
    let alertDate: AttributedString? =
      if let date = self.date {
        date.attributedString(withContentAttributes: .danger)
      } else {
        nil
      }

    let description: AttributedString? =
      if let description = self.description {
        description.attributedString(withContentAttributes: .danger)
      } else {
        nil
      }

    let dataInvolved: AttributedString? =
      if let details = self.details {
        details.attributedString(withContentJoinedBy: ", ", attributes: .danger)
      } else {
        nil
      }

    let recommendation: AttributedString? =
      if let alertRecommendation = self.recommendation {
        alertRecommendation.attributedString(withContentAttributes: .semibold)
      } else {
        nil
      }

    return [
      alertDate,
      description,
      dataInvolved,
      recommendation,
    ]
    .compactMap { $0 }
    .joined(by: .separator)
    .mergingAttributes(.alertDefault, mergePolicy: .keepCurrent)
  }
}

extension HiddenTrayAlert: UnresolvedAlertShowable {

  func generateMessage() -> AttributedString {
    let alertDate: AttributedString? =
      if let date = self.date {
        date.attributedString(withContentAttributes: .danger)
      } else {
        nil
      }

    let dataInvolved: AttributedString? =
      if let details = details {
        details.attributedString(withContentJoinedBy: ", ", attributes: .danger)
      } else {
        nil
      }

    let recommendation: AttributedString? =
      if let recommendation = recommendation {
        AttributedString(recommendation.string())
      } else {
        nil
      }

    return [
      alertDate,
      dataInvolved,
      recommendation,
    ]
    .compactMap { $0 }
    .joined(by: .separator)
    .mergingAttributes(.alertDefault, mergePolicy: .keepCurrent)
  }
}

extension DataLeakContentTrayAlert: UnresolvedAlertShowable {

  func generateMessage() -> AttributedString {
    let alertDate: AttributedString? =
      if let date = self.date {
        date.attributedString(withContentAttributes: .danger)
      } else {
        nil
      }

    let dataInvolved: AttributedString? =
      if let details = self.details {
        details.attributedString(withContentAttributes: .danger, splittedBy: "_")
      } else {
        nil
      }

    return [
      alertDate,
      dataInvolved,
    ]
    .compactMap { $0 }
    .joined(by: .separator)
    .mergingAttributes(.alertDefault, mergePolicy: .keepCurrent)
  }
}

extension DataLeakPlaintextTrayAlert: UnresolvedAlertShowable {

  public class Actionable: UnresolvedAlertActionableMessage {

    public enum State {
      case visible
      case hidden
    }

    private let clearMessage: AttributedString
    private let passwords: [String]

    public private(set) var message: AttributedString
    public private(set) var state: State = .hidden

    public var icon: Image {
      if state == .hidden {
        return .ds.action.reveal.outlined
      }
      return .ds.action.hide.outlined
    }

    init(message: AttributedString, passwords: [String]) {
      self.clearMessage = message
      self.message = message
      self.passwords = passwords
      updateMessage(for: self.state)
    }

    public func action() {
      self.state = self.state == .hidden ? .visible : .hidden
      updateMessage(for: self.state)
    }

    private func updateMessage(for state: State) {
      if state == .visible {
        self.message = clearMessage
      } else {
        let passwordsString = passwords.joined(separator: ", ")
        guard let passwordsRange = clearMessage.range(of: passwordsString) else {
          return
        }

        var message = clearMessage
        let currentAttributes = clearMessage[passwordsRange].runs.first?.attributes
        let hiddenPasswordBullets = AttributedString(
          "••••••••••••••••••", attributes: currentAttributes ?? .alertDefault)
        message.replaceSubrange(passwordsRange, with: hiddenPasswordBullets)
        self.message = message
      }
    }
  }

  func generateMessage() -> AttributedString {
    let alertDate = date?.attributedString(withContentAttributes: .danger)
    let affectedEmails = details?.attributedString(withContentAttributes: .danger)

    return [
      alertDate,
      affectedEmails,
    ]
    .compactMap { $0 }
    .joined(by: .separator)
    .mergingAttributes(.alertDefault, mergePolicy: .keepCurrent)
  }

  func generateActionableMessage() -> UnresolvedAlertActionableMessage? {
    let leakedPasswords = self.leakedPasswords?.attributedString(withContentAttributes: .danger)

    guard let leakedPasswordsMessage = leakedPasswords else { return nil }
    guard let passwords = self.leakedPasswords?.contents else { return nil }

    return Actionable(message: leakedPasswordsMessage, passwords: passwords)
  }

  func generatePostActionableMessage() -> AttributedString? {
    return self.recommendation?.attributedString(withContentAttributes: .danger)
  }
}

extension Array where Element == NSAttributedString {
  fileprivate func joined(by separator: String) -> NSAttributedString {
    return self.reduce(NSMutableAttributedString()) {
      (result, attributedStringToAppend) -> NSMutableAttributedString in
      if result.string.count > 0 {
        result.append(NSAttributedString(string: separator))
      }
      result.append(attributedStringToAppend)
      return result
    }
  }
}

extension Font {
  fileprivate static var unresolvedAlertFont: Font {
    Font.body
  }
}

extension AttributeContainer {
  fileprivate static var alertDefault: AttributeContainer {
    var container = AttributeContainer()
    container.font = .unresolvedAlertFont
    return container
  }

  fileprivate static var danger: AttributeContainer {
    var container = AttributeContainer()
    container.foregroundColor = Color.ds.text.danger.quiet
    container.font = .unresolvedAlertFont.weight(.medium)

    return container
  }

  fileprivate static var semibold: AttributeContainer {
    var container = AttributeContainer()
    container.font = .unresolvedAlertFont.weight(.semibold)
    return container
  }

  fileprivate static var bold: AttributeContainer {
    var container = AttributeContainer()
    container.font = .unresolvedAlertFont.weight(.bold)
    return container
  }
}
