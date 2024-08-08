import Combine
import CoreSettings

public protocol PasteboardServiceProtocol {
  func set(_ text: String)
}

struct PasteboardServiceMock: PasteboardServiceProtocol {

  let copied: (String) -> Void

  init(copied: @escaping (String) -> Void) {
    self.copied = copied
  }

  func set(_ text: String) {
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

#if canImport(UIKit)
  import Foundation
  import CorePersonalData
  import MobileCoreServices
  import UIKit
  import UniformTypeIdentifiers

  public struct PasteboardService: PasteboardServiceProtocol {

    public let userSettings: UserSettings
    private let pasteboard: UIPasteboard = .general

    public init(userSettings: UserSettings) {
      self.userSettings = userSettings
    }

    public func set(_ text: String) {
      let expirationDelay: TimeInterval? = userSettings[.clipboardExpirationDelay]
      let expirationDate: Date = expirationDelay.map(Date().addingTimeInterval) ?? .distantFuture
      let universalClipboardEnabled: Bool = userSettings[.isUniversalClipboardEnabled] ?? false
      let itemToSave = [UTType.utf8PlainText.identifier: text]
      pasteboard.setItems(
        [itemToSave],
        options: [
          .expirationDate: expirationDate,
          .localOnly: !universalClipboardEnabled,
        ])
    }
  }
#else
  import Cocoa

  extension NSPasteboard.PasteboardType {
    public static let concealed: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(
      rawValue: "org.nspasteboard.ConcealedType")
  }

  public struct PasteboardService: PasteboardServiceProtocol {

    public let userSettings: UserSettings

    public init(userSettings: UserSettings) {
      self.userSettings = userSettings
    }

    public func set(_ text: String) {
      NSPasteboard.general.setPassword(text)
    }

  }

  extension NSPasteboard {
    fileprivate func setPassword(_ password: String) {
      let pasteboard = NSPasteboard.general
      pasteboard.declareTypes([.concealed, .string], owner: nil)
      pasteboard.setString(password, forType: .concealed)
      pasteboard.setString(password, forType: .string)
    }
  }
#endif

extension PasteboardService {
  public static func mock() -> PasteboardService {
    return PasteboardService(userSettings: UserSettings(internalStore: .mock()))
  }
}

public protocol ItemPasteboardProtocol {
  func copy(_ value: String, for item: VaultItem, hasSecureAccess: Bool) -> AnyPublisher<
    Bool, Never
  >
}

extension ItemPasteboardProtocol {
  public func copy(
    _ item: VaultItem,
    valueToCopy: String,
    hasSecureAccess: Bool = false
  ) -> AnyPublisher<Bool, Never> {
    return copy(valueToCopy, for: item, hasSecureAccess: hasSecureAccess)
  }

  public func copy(_ item: CopiablePersonalData & VaultItem, hasSecureAccess: Bool = false)
    -> AnyPublisher<Bool, Never>
  {
    return copy(item.valueToCopy, for: item, hasSecureAccess: hasSecureAccess)
  }
}

public struct ItemPasteboard: ItemPasteboardProtocol {
  private let accessControl: AccessControlProtocol
  private let pasteboardService: PasteboardServiceProtocol

  public init(
    accessControl: AccessControlProtocol,
    pasteboardService: PasteboardServiceProtocol
  ) {
    self.accessControl = accessControl
    self.pasteboardService = pasteboardService
  }

  public func copy(_ value: String, for item: VaultItem, hasSecureAccess: Bool = false)
    -> AnyPublisher<Bool, Never>
  {
    guard type(of: item).requireSecureAccess && !hasSecureAccess else {
      self.updatePasteboard(with: value)
      return Just(true)
        .eraseToAnyPublisher()
    }

    return
      accessControl
      .requestAccess()
      .handleEvents(receiveOutput: { success in
        if success {
          self.updatePasteboard(with: value)
        }
      })
      .eraseToAnyPublisher()
  }

  private func updatePasteboard(with value: String) {
    pasteboardService.set(value)
  }
}

public struct ItemPasteboardMock: ItemPasteboardProtocol {

  let copied: (String, VaultItem) -> Void

  init(copied: @escaping (String, VaultItem) -> Void) {
    self.copied = copied
  }

  public func copy(_ value: String, for item: VaultItem, hasSecureAccess: Bool) -> AnyPublisher<
    Bool, Never
  > {
    copied(value, item)
    return CurrentValueSubject<Bool, Never>(true).eraseToAnyPublisher()
  }
}

extension ItemPasteboardProtocol where Self == ItemPasteboardMock {
  public static func mock(copied: @escaping (String, VaultItem) -> Void = { _, _ in })
    -> ItemPasteboardProtocol
  {
    ItemPasteboardMock(copied: copied)
  }
}
