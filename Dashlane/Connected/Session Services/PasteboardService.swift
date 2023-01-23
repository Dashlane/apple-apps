import Foundation
import MobileCoreServices
import UIKit
import DashlaneAppKit
import CoreSettings
import UniformTypeIdentifiers

struct PasteboardService {

    let userSettings: UserSettings
    private let pasteboard: UIPasteboard = .general

    func set(_ text: String) {

        let expirationDelay: TimeInterval? = userSettings[.clipboardExpirationDelay]
        let expirationDate: Date = expirationDelay.map(Date().addingTimeInterval) ?? .distantFuture
        let universalClipboardEnabled: Bool = userSettings[.isUniversalClipboardEnabled] ?? false
        let itemToSave = [UTType.utf8PlainText.identifier: text]
        pasteboard.setItems([itemToSave], options: [.expirationDate: expirationDate,
                                                    .localOnly: !universalClipboardEnabled])
    }

}
