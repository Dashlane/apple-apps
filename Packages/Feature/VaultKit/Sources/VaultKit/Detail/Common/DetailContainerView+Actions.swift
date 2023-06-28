#if os(iOS)
import SwiftUI
import Combine
import CoreLocalization
import CorePremium
import CoreUserTracking
import DesignSystem
import SwiftTreats
import UIComponents

extension DetailContainerView {
    func onCopyAction(_ success: Bool) {
        guard success else {
            return
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        toast(L10n.Core.kwCopied, image: .ds.action.copy.outlined)
    }

    func save() {
        if let specificSave {
            specificSave()
        } else {
            model.save()
        }

                if self.model.mode.isAdding && Device.isIpadOrMac {
            model.showInVault()
        } else {
            self.model.mode = .viewing
        }
    }

    func delete() {
        Task {
            await self.model.delete()
            await MainActor.run { self.dismiss() }
        }
    }
}
#endif
