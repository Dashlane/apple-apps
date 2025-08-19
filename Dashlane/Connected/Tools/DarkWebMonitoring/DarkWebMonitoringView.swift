import CoreLocalization
import DesignSystem
import SwiftUI
import VaultKit

struct DarkWebMonitoringView: View {

  @StateObject
  var model: DarkWebMonitoringViewModel

  init(model: @autoclosure @escaping () -> DarkWebMonitoringViewModel) {
    _model = .init(wrappedValue: model())
  }

  var body: some View {
    landingView
      .frame(maxHeight: .infinity, alignment: .top)
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(L10n.Localizable.dataleakNotificationTitle)
      .reportPageAppearance(.toolsDarkWebMonitoring)
  }

  @ViewBuilder
  private var landingView: some View {
    switch model.viewState {
    case .loading:
      EmptyView()
    case .premium:
      premiumBody
    case .intro:
      introBody
    case .enabled:
      dwmBody
    }
  }

  private var introBody: some View {
    ToolIntroView(
      icon: ExpressiveIcon(.ds.feature.darkWebMonitoring.outlined),
      title: CoreL10n.DarkWebMonitoringIntro.title
    ) {
      FeatureCard {
        FeatureRow(
          asset: ExpressiveIcon(.ds.web.outlined),
          title: CoreL10n.DarkWebMonitoringIntro.subtitle1,
          description: CoreL10n.DarkWebMonitoringIntro.description1
        )

        FeatureRow(
          asset: ExpressiveIcon(.ds.notification.outlined),
          title: CoreL10n.DarkWebMonitoringIntro.subtitle2,
          description: CoreL10n.DarkWebMonitoringIntro.description2
        )

        FeatureRow(
          asset: ExpressiveIcon(.ds.protection.outlined),
          title: CoreL10n.DarkWebMonitoringIntro.subtitle3,
          description: CoreL10n.DarkWebMonitoringIntro.description3
        )
      }

      Button(CoreL10n.DarkWebMonitoringIntro.cta) {
        model.addEmail()
      }
      .buttonStyle(.designSystem(.titleOnly(.sizeToFit)))
    }
  }

  private var premiumBody: some View {
    DarkWebMonitoringPremiumListView(
      dwmService: model.darkWebMonitoringService,
      actionPublisher: model.actionPublisher)
  }

  @ViewBuilder
  private var dwmBody: some View {
    List {
      DarkWebMonitoringMonitoredEmailsView(
        model: model.headerViewModelFactory.make(actionPublisher: model.actionPublisher)
      )
      .listSectionSpacing(24)

      DarkWebMonitoringBreachListView(
        viewModel: model.listViewModelFactory.make(actionPublisher: model.actionPublisher))

    }
    .listStyle(.ds.insetGrouped)
  }
}

#Preview {
  TabView {
    NavigationView {
      DarkWebMonitoringView(model: .mock)
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}
