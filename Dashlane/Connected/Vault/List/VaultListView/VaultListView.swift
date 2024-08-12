import Combine
import CoreLocalization
import CoreUserTracking
import DesignSystem
import NotificationKit
import SwiftTreats
import SwiftUI
import UIKit
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
    .navigationTitle(
      title ?? model.activeFilter?.title ?? CoreLocalization.L10n.Core.mainMenuHomePage
    )
    .reportPageAppearance(model.activeFilter.page)
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct VaultListView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      VaultListView(model: .mock)
    }
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
    }
  }
}
