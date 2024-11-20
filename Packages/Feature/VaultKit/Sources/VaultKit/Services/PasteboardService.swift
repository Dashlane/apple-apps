import Combine
import CorePersonalData
import CoreSettings
import DashTypes
import Foundation
import MobileCoreServices
import UIKit
import UniformTypeIdentifiers

public protocol PasteboardServiceProtocol {
  func copy(_ text: String)
}

public struct PasteboardService: PasteboardServiceProtocol {

  public let userSettings: UserSettings
  private let pasteboard: UIPasteboard = .general

  public init(userSettings: UserSettings) {
    self.userSettings = userSettings
  }

  public func copy(_ text: String) {
    let expirationDelay: TimeInterval? = userSettings[.clipboardExpirationDelay]
    let expirationDate: Date = expirationDelay.map(Date().addingTimeInterval) ?? .distantFuture
    let universalClipboardEnabled: Bool = userSettings[.isUniversalClipboardEnabled] ?? false
    pasteboard.copy(
      text,
      options: [
        .expirationDate: expirationDate,
        .localOnly: !universalClipboardEnabled,
      ])
  }
}

extension UIPasteboard: PasteboardServiceProtocol {
  func copy(_ text: String, options: [UIPasteboard.OptionsKey: Any]) {
    let itemToSave = [UTType.utf8PlainText.identifier: text]
    setItems([itemToSave], options: options)
  }

  public func copy(_ text: String) {
    copy(text, options: [:])
  }
}

struct PasteboardServiceMock: PasteboardServiceProtocol {
  let copied: (String) -> Void

  init(copied: @escaping (String) -> Void) {
    self.copied = copied
  }

  func copy(_ text: String) {
    self.copied(text)
  }
}

extension PasteboardServiceProtocol where Self == PasteboardService {
  public static func mock(copied: @escaping (String) -> Void = { _ in })
    -> PasteboardServiceProtocol
  {
    PasteboardServiceMock(copied: copied)
  }
}
