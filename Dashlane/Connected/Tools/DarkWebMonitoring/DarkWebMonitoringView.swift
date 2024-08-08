import Combine
import CorePersonalData
import DesignSystem
import SecurityDashboard
import SwiftUI
import UIDelight

struct DarkWebMonitoringView: View {

  @StateObject
  var model: DarkWebMonitoringViewModel

  init(model: @autoclosure @escaping () -> DarkWebMonitoringViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    Group {
      if model.shouldShowIntroScreen == true {
        premiumBody
      } else {
        dwmBody
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(L10n.Localizable.dataleakNotificationTitle)
    .reportPageAppearance(.toolsDarkWebMonitoring)
  }

  @ViewBuilder
  private var premiumBody: some View {
    DarkWebMonitoringPremiumListView(
      dwmService: model.darkWebMonitoringService,
      actionPublisher: model.actionPublisher
    ) {
      model.addEmail()
    }
  }

  @ViewBuilder
  private var dwmBody: some View {
    VStack(alignment: .leading, spacing: 0) {
      DarkWebMonitoringMonitoredEmailsView(
        model: model.headerViewModelFactory.make(actionPublisher: model.actionPublisher)
      )
      .layoutPriority(1)

      Text(L10n.Localizable.darkWebMonitoringListViewSectionHeaderTitle.uppercased())
        .font(.system(.body))
        .fontWeight(.medium)
        .padding(.leading, 16)
        .padding(.top, 24)
        .foregroundColor(.ds.text.neutral.quiet)

      DarkWebMonitoringBreachListView(
        viewModel: model.listViewModelFactory.make(actionPublisher: model.actionPublisher))
    }.background(.ds.background.default.edgesIgnoringSafeArea(.top))
  }
}

struct DarkWebMonitoringView_Previews: PreviewProvider {
  static var previews: some View {

    MultiContextPreview {
      TabView {
        NavigationView {
          DarkWebMonitoringView(model: .mock)
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
      }
    }
  }
}
