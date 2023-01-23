import Foundation
import SwiftUI

enum SharingDeactivationReason: Error {
    case b2bSharingDisabled
}

extension Alert {
    static var b2bSharingDisabled: Alert {
        return Alert(title: Text(L10n.Localizable.teamSpacesSharingDisabledMessageTitle),
                     message: Text(L10n.Localizable.teamSpacesSharingDisabledMessageBody))
    }
    
    
    init(_ deactivation: SharingDeactivationReason) {
        switch deactivation {
        case .b2bSharingDisabled:
            self = .b2bSharingDisabled
        }
    }
}
