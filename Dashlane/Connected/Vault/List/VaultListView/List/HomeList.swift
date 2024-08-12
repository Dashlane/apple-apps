import NotificationKit
import SwiftTreats
import SwiftUI
import VaultKit

struct HomeList: View {

  @ObservedObject
  var model: HomeListViewModel

  @Binding
  var activeFilter: ItemCategory?

  init(
    activeFilter: Binding<ItemCategory?>,
    model: HomeListViewModel
  ) {
    self._activeFilter = activeFilter
    self.model = model
  }

  var body: some View {
    VStack(spacing: 0) {
      header

      VaultItemsList(
        model: model.itemsListViewModel,
        header: {
          if activeFilter == nil {
            HomeTopBannerView(model: model.makeHomeAnnouncementsViewModel())
          }
        }
      )
      .reportPageAppearance(activeFilter.page)

      HomeBottomBannerView(model: model.makeHomeBottomBannerViewModel())
        .accessibilitySortPriority(.bottomAnnouncement)
    }
    .onChange(of: activeFilter) { newValue in
      self.model.filter(newValue)
      self.model.sessionActivityReporter.reportPageShown(newValue.page)
    }
    .onAppear {
      let filter = activeFilter
      self.model.filter(filter)
    }
  }

  private var header: some View {
    VStack(spacing: 0) {
      if !Device.isIpadOrMac {
        FiltersView(activeFilter: $activeFilter)
      }

    }
    .accessibilitySortPriority(.header)
  }
}

struct HomeList_Previews: PreviewProvider {
  static var previews: some View {
    HomeList(activeFilter: .constant(nil), model: .mock)
  }
}
