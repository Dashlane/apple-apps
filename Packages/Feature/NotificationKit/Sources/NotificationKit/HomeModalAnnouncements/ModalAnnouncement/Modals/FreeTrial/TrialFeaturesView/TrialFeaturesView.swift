import CoreLocalization
import CorePremium
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

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

      Text(CoreL10n.currentPlanTitleTrial)
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .multilineTextAlignment(.leading)
        .padding()

      Group {
        capability(CoreL10n.currentBenefitPasswordsUnlimited)
        capability(CoreL10n.currentBenefitDevicesSyncUnlimited)
        capability(CoreL10n.currentBenefitSecureNotes)
        capability(CoreL10n.currentBenefitDarkWebMonitoring, moreInfo: dwmMoreInfo)
        if case .available = secureWifiState {
          capability(CoreL10n.currentBenefitVpn)
        }
      }

      Infobox(CoreL10n.currentPlanSuggestionTrialText)
        .padding(.horizontal)

      Spacer()

      Button(CoreL10n.currentPlanCtaAllPlans) {
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
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
    .reportPageAppearance(.currentPlan)
  }

  @ViewBuilder
  func capability(_ title: String, moreInfo: CapabilityMoreInfo? = nil) -> some View {
    HStack {
      Image.ds.feedback.success.filled
        .foregroundStyle(Color.ds.text.positive.quiet)
      Text(title).foregroundStyle(Color.ds.text.neutral.standard)
      if let moreInfo {
        moreInfoButton(moreInfo)
      }
    }
    .padding(.leading)
    .padding(.bottom)
  }

  private var dwmMoreInfo: CapabilityMoreInfo {
    CapabilityMoreInfo(
      title: CoreL10n.currentBenefitMoreInfoDarkWebMonitoringTitle,
      text: CoreL10n.currentBenefitMoreInfoDarkWebMonitoringText,
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
          Image(.diamond)
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
    if Device.is(.pad, .mac, .vision) {
      return Image(.trialHeaderIpad)
    } else {
      return Image(.trialHeader)
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
          .foregroundStyle(Color.ds.text.brand.standard)
      }
    )
    .alert(
      moreInfo.title,
      isPresented: $showAlert,
      actions: {
        Button(CoreL10n.kwButtonOk) {}
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
  let page: UserTrackingFoundation.Page
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

#if DEBUG
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
#endif
