import CoreLocalization
import CorePremium
import CoreUserTracking
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct TrialFeaturesView: View {

  let viewModel: TrialFeaturesViewModel

  let dismissFlow: DismissAction?

  @Environment(\.dismiss) private var dismissView

  @State
  private var showAlert = false

  @CapabilityState(.secureWiFi)
  var secureWifiState

  public init(viewModel: TrialFeaturesViewModel, dismissFlow: DismissAction? = nil) {
    self.viewModel = viewModel
    self.dismissFlow = dismissFlow
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      banner

      Text(L10n.Core.currentPlanTitleTrial)
        .font(.title)
        .fontWeight(.bold)
        .multilineTextAlignment(.leading)
        .padding()

      Group {
        capability(L10n.Core.currentBenefitPasswordsUnlimited)
        capability(L10n.Core.currentBenefitDevicesSyncUnlimited)
        capability(L10n.Core.currentBenefitSecureNotes)
        capability(L10n.Core.currentBenefitDarkWebMonitoring, moreInfo: dwmMoreInfo)
        if case .available = secureWifiState {
          capability(L10n.Core.currentBenefitVpn)
        }
      }

      Infobox(L10n.Core.currentPlanSuggestionTrialText)
        .padding(.horizontal)

      Spacer()

      Button(L10n.Core.currentPlanCtaAllPlans) {
        viewModel.deepLinkingService.handle(.goToPremium)
        viewModel.activityReporter.report(
          UserEvent.CallToAction(
            callToActionList: [.allOffers], chosenAction: .allOffers, hasChosenNoAction: false))
      }
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.horizontal)
      .padding(.bottom)
    }
    .navigationBarBackButtonHidden(true)
    .backgroundColorIgnoringSafeArea(.ds.background.default)
    .reportPageAppearance(.currentPlan)
  }

  @ViewBuilder
  func capability(_ title: String, moreInfo: CapabilityMoreInfo? = nil) -> some View {
    HStack {
      Image.ds.feedback.success.filled
        .foregroundColor(.ds.text.positive.quiet)
      Text(title).foregroundColor(.ds.text.neutral.standard)
      if let moreInfo {
        moreInfoButton(moreInfo)
      }
    }
    .padding(.leading)
    .padding(.bottom)
  }

  private var dwmMoreInfo: CapabilityMoreInfo {
    CapabilityMoreInfo(
      title: L10n.Core.currentBenefitMoreInfoDarkWebMonitoringTitle,
      text: L10n.Core.currentBenefitMoreInfoDarkWebMonitoringText,
      page: .currentPlanDwmLearnMore)
  }

  @ViewBuilder
  var banner: some View {
    ZStack(
      alignment: .top,
      content: {
        bannerImage
          .resizable()
          .layoutPriority(-1)

        HStack {
          Image(asset: Asset.diamond)
            .padding(.top, 50)
            .padding(.leading, 20)
          Spacer()
          AnnouncementCloseButton(dismiss: {
            viewModel.activityReporter.report(
              UserEvent.CallToAction(callToActionList: [.allOffers], hasChosenNoAction: true))
            dismiss()
          })
        }
      })
  }

  var bannerImage: SwiftUI.Image {
    if Device.isIpadOrMac {
      return Image(asset: Asset.trialHeaderIpad)
    } else {
      return Image(asset: Asset.trialHeader)
    }
  }

  @ViewBuilder
  func moreInfoButton(_ moreInfo: CapabilityMoreInfo) -> some View {
    Button(
      action: {
        self.showAlert.toggle()
        viewModel.activityReporter.reportPageShown(moreInfo.page)
      },
      label: {
        Image.ds.feedback.info.outlined
          .foregroundColor(.ds.text.brand.standard)
      }
    )
    .alert(
      moreInfo.title,
      isPresented: $showAlert,
      actions: {
        Button(L10n.Core.kwButtonOk) {}
      },
      message: {
        Text(moreInfo.text)
      }
    )

  }

  private func dismiss() {
    if let dismissFlow = dismissFlow {
      dismissFlow()
    } else {
      dismissView()
    }
  }
}

struct CapabilityMoreInfo {
  let title: String
  let text: String
  let page: CoreUserTracking.Page
}

extension CapabilityServiceProtocol {
  var hasSecureWifi: Bool {
    switch status(of: .secureWiFi) {
    case .available:
      return true
    default:
      return false
    }
  }
}

private struct PreviewContent: View {
  @Environment(\.dismiss) var dismissFlow

  var body: some View {
    TrialFeaturesView(
      viewModel: .init(
        capabilityService: .mock(),
        deepLinkingService: NotificationKitDeepLinkingServiceMock(),
        activityReporter: .mock
      ),
      dismissFlow: dismissFlow
    )
  }
}

#Preview {
  PreviewContent()
}
