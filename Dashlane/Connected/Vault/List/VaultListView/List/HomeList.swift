import CoreFeature
import CorePremium
import NotificationKit
import SwiftTreats
import SwiftUI
import VaultKit

struct HomeList: View {

  @ObservedObject
  var model: HomeListViewModel

  @Binding
  var activeFilter: ItemCategory?

  @CapabilityState(.secretManagement)
  var secretManagementStatus

  @FeatureState(.wifiCredential)
  var isWiFiCredentialEnabled

  init(
    activeFilter: Binding<ItemCategory?>,
    model: HomeListViewModel
  ) {
    self._activeFilter = activeFilter
    self.model = model
  }

  var body: some View {
    VaultItemsList(
      model: model.itemsListViewModel,
      header: {
        if activeFilter == nil {
          HomeTopBannerView(model: model.makeHomeAnnouncementsViewModel())
        }
      }
    )
    .reportPageAppearance(activeFilter.page)
    .safeAreaInset(edge: .top) {
      header
        .background(Color.ds.background.default, ignoresSafeAreaEdges: .top)

    }
    .safeAreaInset(edge: .bottom) {
      HomeBottomBannerView(model: model.makeHomeBottomBannerViewModel())
        .accessibilitySortPriority(.bottomAnnouncement)
        .background(Color.ds.background.default, ignoresSafeAreaEdges: .bottom)
    }
    .onChange(of: activeFilter) { _, newValue in
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
      if !Device.is(.pad, .mac, .vision) {
        FiltersView(
          activeFilter: $activeFilter,
          enabledFilters: enabledFilters)
      }

    }
    .accessibilitySortPriority(.header)
  }

  private var enabledFilters: [ItemCategory] {
    ItemCategory.allCases.lazy
      .filter { category in
        switch category {
        case .secrets:
          return secretManagementStatus.isAvailable
        case .wifi:
          return isWiFiCredentialEnabled
        default:
          return true
        }
      }
  }
}

struct HomeList_Previews: PreviewProvider {
  static var previews: some View {
    HomeList(activeFilter: .constant(nil), model: .mock)
  }
}
