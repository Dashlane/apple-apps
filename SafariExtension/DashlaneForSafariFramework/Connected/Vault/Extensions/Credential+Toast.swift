import Foundation
import SwiftUI
import CorePersonalData
import VaultKit
import UIComponents

extension ToastAction {
    func callAsFunction(_ action: CopyCredentialAction, for item: VaultItem) {
        let announcement = action.copyFeedback(forWebsite: item.displayTitle)
        guard let text = try? AttributedString(markdown: action.copyFeedback(forWebsite: "**" + item.displayTitle + "**")) else {
            return
        }
        self.callAsFunction(Text(text), image: .ds.action.copy.outlined, accessibilityAnnouncement: announcement)
    }
}
