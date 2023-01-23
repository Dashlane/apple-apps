import CorePersonalData
import SwiftUI
import CoreSpotlight
import CoreLocalization
import DocumentServices

public protocol SecureItem {
    var secured: Bool {get set}
}

extension SecureNote: VaultItem, SecureItem {
    public var enumerated: VaultItemEnumeration {
         return .secureNote(self)
    }

    public var localizedTitle: String {
        return displayTitle
    }

    public var localizedSubtitle: String {
        guard !secured else {
            return L10n.Core.KWSecureNoteIOS.protectedMessage
        }

        return displaySubtitle ?? ""
    }

    public static var localizedName: String {
        L10n.Core.kwSecureNoteIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwSecureNoteIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addSecureNote
    }


        public var logData: VaultItemUsageLogData {
        return VaultItemUsageLogData(color: color.rawValue,
                                            secure: secured,
                                            size: content.count,
                                            category: category?.name,
                                            attachmentCount: attachments?.count ?? 0)
    }
}
