import DesignSystem
import Foundation
import SecurityDashboard
import SwiftUI

private protocol PopupAlertShowable {
  func generateMessage() -> AttributedString
}

struct PopupAlert {

  let alert: PopupAlertProtocol
  let title: String
  let message: AttributedString

  init(_ popupAlert: PopupAlertProtocol) {
    self.alert = popupAlert
    self.title = popupAlert.title

    guard let showableAlert = popupAlert as? PopupAlertShowable else {
      fatalError()
    }

    var content: AttributedString = .init("\n", attributes: .alertDefault)
    content.append(showableAlert.generateMessage())
    self.message = content
  }
}

extension DashlaneSixPopupAlert: PopupAlertShowable {
  func generateMessage() -> AttributedString {
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
      description,
      dataInvolved,
      recommendation,
    ]
    .compactMap { $0 }
    .joined(by: .separator)
    .mergingAttributes(.alertDefault, mergePolicy: .keepCurrent)
  }
}

extension DataLeakHiddenPopupAlert: PopupAlertShowable {
  func generateMessage() -> AttributedString {
    let date: AttributedString? =
      if let alertDate = self.date {
        alertDate.attributedString(withContentAttributes: .danger)
      } else {
        nil
      }

    let dataInvolved: AttributedString? =
      if let details = self.details {
        details.attributedString(withContentJoinedBy: ", ", attributes: .danger)
      } else {
        nil
      }

    let explanations: AttributedString? =
      if let alertExplanations = self.explanations {
        AttributedString(alertExplanations.title.data, attributes: .bold)
          + AttributedString("\n\(alertExplanations.contents.first!)", attributes: .semibold)
      } else {
        nil
      }

    return [
      date,
      dataInvolved,
      explanations,
    ]
    .compactMap { $0 }
    .joined(by: .separator)
    .mergingAttributes(.alertDefault, mergePolicy: .keepCurrent)
  }
}

extension DataLeakContentPopupAlert: PopupAlertShowable {
  func generateMessage() -> AttributedString {
    let dataInvolved: AttributedString? =
      if let details = self.details {
        details.attributedString(withContentAttributes: .danger, splittedBy: "_")
      } else {
        nil
      }

    return [
      dataInvolved
    ]
    .compactMap { $0 }
    .joined(by: .separator)
    .mergingAttributes(.alertDefault, mergePolicy: .keepCurrent)
  }
}

extension DataLeakPlaintextPopupAlert: PopupAlertShowable {

  func generateMessage() -> AttributedString {
    let alertDate = date?.attributedString(withContentAttributes: .bold)
    let affectedPasswords = details?.attributedString(withContentAttributes: .danger)
    let otherCredentialsImpacted = self.recommendation?.attributedString(
      withContentAttributes: .danger)

    return [
      alertDate,
      affectedPasswords,
      otherCredentialsImpacted,
    ]
    .compactMap { $0 }
    .joined(by: .separator)
    .mergingAttributes(.alertDefault, mergePolicy: .keepCurrent)
  }

}

extension Font {
  fileprivate static var alertFont: Font {
    Font.footnote
  }
}

extension AttributeContainer {
  fileprivate static var alertDefault: AttributeContainer {
    var container = AttributeContainer()
    container.font = .alertFont
    return container
  }

  fileprivate static var danger: AttributeContainer {
    var container = AttributeContainer()
    container.foregroundColor = Color.ds.text.danger.quiet
    container.font = .alertFont.weight(.medium)

    return container
  }

  fileprivate static var semibold: AttributeContainer {
    var container = AttributeContainer()
    container.font = .alertFont.weight(.semibold)
    return container
  }

  fileprivate static var bold: AttributeContainer {
    var container = AttributeContainer()
    container.font = .alertFont.weight(.bold)
    return container
  }
}

extension Collection<AttributedString> {
  func joined(by separator: AttributedString) -> AttributedString {
    guard let first = self.first else {
      return AttributedString("")
    }

    var result = first
    for item in self.dropFirst() {
      result += separator + item
    }
    return result
  }
}

extension AttributedString {
  static var separator: AttributedString {
    "\n\n"
  }
}
