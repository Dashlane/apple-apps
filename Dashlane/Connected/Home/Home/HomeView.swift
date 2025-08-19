import Combine
import CoreLocalization
import CorePersonalData
import NotificationKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct HomeView: View {
  @StateObject
  var model: HomeViewModel

  @Binding
  var activeFilter: ItemCategory?

  init(model: @escaping @autoclosure () -> HomeViewModel, activeFilter: Binding<ItemCategory?>) {
    self._model = .init(wrappedValue: model())
    self._activeFilter = activeFilter
  }

  @State
  private var bottomBannerHeight: CGFloat = 0

  var body: some View {
    VaultSearchView(
      model: model.makeSearchViewModel(),
      initialView: {
        HomeList(
          activeFilter: $activeFilter,
          model: model.homeListViewModel)
      }
    )
    .navigationTitle(CoreL10n.mainMenuHomePage)
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      HomeView(model: HomeViewModel.mock, activeFilter: .constant(nil))
    }
  }
}
