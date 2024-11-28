import Combine
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

struct DarkWebMonitoringPremiumListView: View {

  private let isDwmEnabled: Bool
  private let actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  let completion: () -> Void

  init(
    isDwmEnabled: Bool,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>,
    completion: @escaping () -> Void = {}
  ) {
    self.isDwmEnabled = isDwmEnabled
    self.actionPublisher = actionPublisher
    self.completion = completion
  }

  init(
    dwmService: DarkWebMonitoringServiceProtocol,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>,
    completion: @escaping () -> Void = {}
  ) {
    self.init(
      isDwmEnabled: dwmService.isDwmEnabled, actionPublisher: actionPublisher,
      completion: completion)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        title
        VStack(alignment: .leading, spacing: 16) {
          premiumBenefitItem(
            title: L10n.Localizable.dataleakmonitoringNoEmailBenefitsSurveillanceTitle,
            content: L10n.Localizable.dataleakmonitoringNoEmailBenefitsSurveillanceDescription,
            icon: Image(asset: FiberAsset.dwmMonitor))
          Divider()
          premiumBenefitItem(
            title: L10n.Localizable.dataleakmonitoringNoEmailBenefitsFirstTitle,
            content: L10n.Localizable.dataleakmonitoringNoEmailBenefitsFirstDescription,
            icon: Image(asset: FiberAsset.dwmAlert))
          Divider()
          premiumBenefitItem(
            title: L10n.Localizable.dataleakmonitoringNoEmailBenefitsExpertTitle,
            content: L10n.Localizable.dataleakmonitoringNoEmailBenefitsExpertDescription,
            icon: Image(asset: FiberAsset.dwmExpert))
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
    Group {
      if isDwmEnabled {
        Text(L10n.Localizable.darkWebMonitoringPremiumViewTitlePremiumUser)
      } else {
        Text(L10n.Localizable.darkWebMonitoringPremiumViewTitleFreeUser)
      }
    }
    .font(DashlaneFont.custom(26.0, .bold).font)
    .padding(.bottom, 10)
    .padding(.top, 16)
    .fiberAccessibilityAddTraits(.isHeader)
  }

  private func premiumBenefitItem(title: String, content: String, icon: Image) -> some View {
    HStack(alignment: .top, spacing: 0) {
      icon
        .foregroundColor(.ds.text.brand.quiet)
        .fiberAccessibilityHidden(true)
      VStack(alignment: .leading) {
        Text(title)
          .font(.body)
          .foregroundColor(.ds.text.neutral.standard)
          .bold()
          .padding(.bottom, 4)
          .minimumScaleFactor(1)
          .accessibilityAddTraits(.isHeader)
        Text(content)
          .font(.callout)
          .minimumScaleFactor(1)
          .foregroundColor(.ds.text.neutral.quiet)
      }
      .padding(.leading, 20)
    }
  }

  @ViewBuilder
  private var premiumButton: some View {
    Button(
      isDwmEnabled
        ? L10n.Localizable.dataleakmonitoringNoEmailStartCta
        : L10n.Localizable.kwFreeUserPremiumPromptYes
    ) {
      if isDwmEnabled {
        completion()
      } else {
        upgradeToPremium()
      }
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
