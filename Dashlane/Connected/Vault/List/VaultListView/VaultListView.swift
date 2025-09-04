import Combine
import CoreLocalization
import DesignSystem
import NotificationKit
import SwiftTreats
import SwiftUI
import UIKit
import UserTrackingFoundation
import VaultKit

struct VaultListView: View {
  @StateObject var model: VaultListViewModel

  let title: String?

  init(
    model: @autoclosure @escaping () -> VaultListViewModel,
    title: String? = nil
  ) {
    self._model = .init(wrappedValue: model())
    self.title = title
  }

  var body: some View {
    VaultSearchView(
      model: model.makeSearchViewModel(),
      initialView: {
        VaultItemsList(model: model.itemsListViewModel)
      }
    )
    .navigationTitle(title ?? model.activeFilter?.title ?? CoreL10n.mainMenuHomePage)
    .reportPageAppearance(model.activeFilter.page)
    .navigationBarTitleDisplayMode(.inline)
  }
}

extension ItemCategory? {
  var page: Page {
    switch self {
    case .none:
      return .homeAll
    case .payments:
      return .homePayments
    case .credentials:
      return .homePasswords
    case .secureNotes:
      return .homeSecureNotes
    case .personalInfo:
      return .homePersonalInfo
    case .ids:
      return .homeIds
    case .secrets:
      return .homeSecureNotes
    case .wifi:
      return .homeSecureNotes
    }
  }
}

#Preview {
  VaultListView(model: .mock)
}
