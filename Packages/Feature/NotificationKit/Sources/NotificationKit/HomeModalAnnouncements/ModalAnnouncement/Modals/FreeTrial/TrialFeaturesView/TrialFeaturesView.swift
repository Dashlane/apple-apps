import SwiftUI
import UIDelight
import SwiftTreats
import CoreUserTracking
import UIComponents
import DesignSystem
import CoreLocalization
import CorePremium

public struct TrialFeaturesView: View {

    let viewModel: TrialFeaturesViewModel

        let dismiss: DismissAction

    @State
    private var showAlert = false

    public init(viewModel: TrialFeaturesViewModel, dismiss: DismissAction) {
        self.viewModel = viewModel
        self.dismiss = dismiss
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
                if viewModel.capabilityService.hasSecureWifi {
                    capability(L10n.Core.currentBenefitVpn)
                }
            }

            Infobox(title: L10n.Core.currentPlanSuggestionTrialText)
                .padding(.horizontal)

            Spacer()

            RoundedButton(L10n.Core.currentPlanCtaAllPlans, action: {
                viewModel.deepLinkingService.handle(.goToPremium)
                viewModel.activityReporter.report(UserEvent.CallToAction(callToActionList: [.allOffers], chosenAction: .allOffers, hasChosenNoAction: false))
            })
                .roundedButtonLayout(.fill)
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
            moreInfoButton(moreInfo)
        }
        .padding(.leading)
        .padding(.bottom)
    }

    private var dwmMoreInfo: CapabilityMoreInfo {
        CapabilityMoreInfo(title: L10n.Core.currentBenefitMoreInfoDarkWebMonitoringTitle,
                           text: L10n.Core.currentBenefitMoreInfoDarkWebMonitoringText,
                           page: .currentPlanDwmLearnMore)
    }

    @ViewBuilder
    var banner: some View {
        ZStack(alignment: .top, content: {
            bannerImage
                .resizable()
                .layoutPriority(-1)

            HStack {
                Image(asset: Asset.diamond)
                    .padding(.top, 50)
                    .padding(.leading, 20)
                Spacer()
                AnnouncementCloseButton(dismiss: {
                    viewModel.activityReporter.report(UserEvent.CallToAction(callToActionList: [.allOffers], hasChosenNoAction: true))
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
    func moreInfoButton(_ moreInfo: CapabilityMoreInfo?) -> some View {
        if let moreInfo = moreInfo {
            Button(action: {
                self.showAlert.toggle()
                viewModel.activityReporter.reportPageShown(moreInfo.page)
            }, label: {
                Image.ds.feedback.info.outlined
                    .foregroundColor(.ds.text.brand.standard)
            })
            .alert(isPresented: $showAlert) { () -> Alert in
                Alert(title: Text(moreInfo.title), message: Text(moreInfo.text))
            }
        } else {
            EmptyView()
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
        switch state(of: .secureWiFi) {
        case .available:
            return true
        default:
            return false
        }
    }
}

struct TrialFeaturesView_Previews: PreviewProvider {

    struct ContainerView: View {
        @Environment(\.dismiss) var dismiss

        var body: some View {
            TrialFeaturesView(viewModel: .init(capabilityService: CapabilityServiceMock(),
                                               deepLinkingService: NotificationKitDeepLinkingServiceMock(),
                                               activityReporter: .fake),
                              dismiss: dismiss)
        }
    }

    static var previews: some View {
        MultiContextPreview {
            ContainerView()
        }

    }
}
