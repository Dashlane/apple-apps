import CoreTypes
import LoginKit
import SwiftUI
import UIDelight

@available(iOS 18, *)
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
struct ContextMenuVaultItemsProviderFlow: View {
  @Environment(\.openURL)
  private var openURL

  @ObservedObject
  var model: ContextMenuVaultItemsProviderFlowModel

  var body: some View {
    StepBasedNavigationView(steps: $model.steps) { step in
      switch step {
      case .list(let category):
        ContextMenuListView(model: model.makeContextMenuListViewModel(category: category))
      case .detailView(let item):
        ContextMenuDetailView(model: model.makeDetailViewModel(), vaultItem: item)
      case .frozen:
        Rectangle()
          .onAppear {
            openURL(URL(string: "dashlane:///getpremium?frozen=true")!)
          }
      }
    }
    .tint(.ds.accentColor)
    .modifier(AutofillConnectedEnvironmentViewModifier(model: model.environmentModelFactory.make()))
    .modifier(AccessControlRequestViewModifier(model: model.accessControlModelFactory.make()))
  }

}
