import Combine
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct DarkWebMonitoringPremiumListView: View {

  private let isDwmEnabled: Bool
  private let actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>

  init(
    isDwmEnabled: Bool,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  ) {
    self.isDwmEnabled = isDwmEnabled
    self.actionPublisher = actionPublisher
  }

  init(
    dwmService: DarkWebMonitoringServiceProtocol,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>,
    completion: @escaping () -> Void = {}
  ) {
    self.init(isDwmEnabled: dwmService.isDwmEnabled, actionPublisher: actionPublisher)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        title
        VStack(alignment: .leading, spacing: 16) {
          premiumBenefitItem(
            title: L10n.Localizable.dataleakmonitoringNoEmailBenefitsSurveillanceTitle,
            content: L10n.Localizable.dataleakmonitoringNoEmailBenefitsSurveillanceDescription,
            icon: Image(.DarkWeb.PremiumBenefits.dwmMonitor))
          Divider()
          premiumBenefitItem(
            title: L10n.Localizable.dataleakmonitoringNoEmailBenefitsFirstTitle,
            content: L10n.Localizable.dataleakmonitoringNoEmailBenefitsFirstDescription,
            icon: Image(.DarkWeb.PremiumBenefits.dwmAlert))
          Divider()
          premiumBenefitItem(
            title: L10n.Localizable.dataleakmonitoringNoEmailBenefitsExpertTitle,
            content: L10n.Localizable.dataleakmonitoringNoEmailBenefitsExpertDescription,
            icon: Image(.DarkWeb.PremiumBenefits.dwmExpert))
        }
        premiumButton
          .padding(.bottom, 12)
      }
      .padding(.horizontal, 24)
    }
    .scrollContentBackgroundStyle(.alternate)
  }

  @ViewBuilder
  private var title: some View {
    Text(L10n.Localizable.darkWebMonitoringPremiumViewTitleFreeUser)
      .textStyle(.title.section.large)
      .foregroundStyle(Color.ds.text.neutral.standard)
      .padding(.bottom, 10)
      .padding(.top, 16)
      .fiberAccessibilityAddTraits(.isHeader)
  }

  private func premiumBenefitItem(title: String, content: String, icon: Image) -> some View {
    HStack(alignment: .top, spacing: 0) {
      icon
        .foregroundStyle(Color.ds.text.brand.quiet)
        .fiberAccessibilityHidden(true)
      VStack(alignment: .leading) {
        Text(title)
          .font(.body)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .bold()
          .padding(.bottom, 4)
          .minimumScaleFactor(1)
          .accessibilityAddTraits(.isHeader)
        Text(content)
          .font(.callout)
          .minimumScaleFactor(1)
          .foregroundStyle(Color.ds.text.neutral.quiet)
      }
      .padding(.leading, 20)
    }
  }

  @ViewBuilder
  private var premiumButton: some View {
    Button(L10n.Localizable.kwFreeUserPremiumPromptYes) {
      upgradeToPremium()
    }
    .buttonStyle(.designSystem(.titleOnly))
  }

  private func upgradeToPremium() {
    actionPublisher.send(.upgradeToPremium)
  }
}

struct DarkWebMonitoringPremiumListView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(deviceRange: .some([.iPhoneSE, .iPhone11])) {
      DarkWebMonitoringPremiumListView(isDwmEnabled: false, actionPublisher: .init())
      DarkWebMonitoringPremiumListView(isDwmEnabled: true, actionPublisher: .init())
    }
  }
}
