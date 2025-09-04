import Combine
import CoreLocalization
import CorePersonalData
import CorePremium
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UserTrackingFoundation

extension DetailContainerView {
  func onCopyAction(_ success: Bool) {
    guard success else {
      return
    }
    #if os(iOS)
      UINotificationFeedbackGenerator().notificationOccurred(.success)
    #endif
    toast(CoreL10n.kwCopied, image: .ds.action.copy.outlined)
  }

  func save() {
    func savePostOperations() {
      if model.mode.isAdding && Device.is(.pad, .mac, .vision) {
        dismiss()

        if let item = model.item as? SecureItem, item.secured {
          return
        }

        model.showInVault()
      } else {
        model.mode = .viewing
      }
    }

    if let specificSave {
      Task {
        await specificSave()
        await MainActor.run {
          savePostOperations()
        }
      }
    } else {
      Task {
        await model.save()
        await MainActor.run {
          savePostOperations()
        }
      }
    }
  }

  func askDelete() {
    Task {
      deleteRequest.itemDeleteBehavior = try await model.itemDeleteBehavior()
      deleteRequest.isPresented = true
    }
  }

  func delete() {
    Task {
      await model.delete()
      await MainActor.run { dismiss() }
    }
  }
}
