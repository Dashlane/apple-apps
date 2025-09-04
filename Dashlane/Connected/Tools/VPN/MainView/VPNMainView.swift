import Combine
import CoreLocalization
import CorePersonalData
import CoreTypes
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct VPNMainView: View {

  @ObservedObject var model: VPNMainViewModel
  @State private var isPresentingInfoModal = false

  @Environment(\.toast)
  var toast

  var body: some View {
    ZStack {
      switch model.mode {
      case .activationNeeded:
        activationNeededView
      case .activated:
        activatedView
      }
    }
    .navigationTitle(L10n.Localizable.mobileVpnTitle)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
  }

  private var activationNeededView: some View {
    ToolIntroView(
      icon: ExpressiveIcon(.ds.feature.vpn.outlined),
      title: CoreL10n.VpnIntro.title
    ) {
      FeatureCard {
        FeatureRow(
          asset: ExpressiveIcon(.ds.laptopCheckmark.outlined),
          title: CoreL10n.VpnIntro.subtitle1,
          description: CoreL10n.VpnIntro.description1)

        FeatureRow(
          asset: ExpressiveIcon(.ds.web.outlined),
          title: CoreL10n.VpnIntro.subtitle2,
          description: CoreL10n.VpnIntro.description2)
      }

      mainButton
    }
  }

  private var activatedView: some View {
    ScrollView {
      VStack(spacing: 24) {
        titleView

        credentialView

        mainButton

        Spacer()

        faqSection
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 24)
    }
    .reportPageAppearance(.toolsVpn)
  }

  @ViewBuilder
  private var credentialView: some View {
    if let credential = model.credential as? Credential {
      VStack {
        HStack(spacing: 8) {
          VaultItemIconView(
            isListStyle: true,
            model: VaultItemIconViewModel(
              item: credential,
              domainIconLibrary: model.iconService.domain))
          Text("Hotspot Shield")
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(Color.ds.text.neutral.catchy)

          Spacer()
        }

        TextDetailField(
          title: CoreL10n.KWAuthentifiantIOS.login,
          text: Binding.constant(credential.email),
          actions: [.copy(copy)]
        )
        .actions([.copy(copy)])
        .fiberFieldType(.email)
        .padding(.top, 26)
        .fieldEditionDisabled()

        SecureDetailField(
          title: CoreL10n.KWAuthentifiantIOS.password,
          text: Binding.constant(credential.password),
          onRevealAction: { _ in },
          actions: [.copy(copy)]
        )
        .actions([.copy(copy)])
        .fiberFieldType(.password)
        .fieldEditionDisabled()
      }
      .padding(16)
      .background(Color.ds.container.expressive.neutral.quiet.idle)
      .cornerRadius(8)
    }
  }

  private var titleView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text(L10n.Localizable.vpnMainViewTitleActivated)
          .textStyle(.title.section.large)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        Text(L10n.Localizable.vpnMainViewSubtitleActivated)
          .textStyle(.body.reduced.regular)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .padding(.top, 8)
      }

      Spacer()
    }
  }

  private var mainButton: some View {
    Button(
      model.mode == .activationNeeded
        ? CoreL10n.VpnIntro.cta : L10n.Localizable.vpnMainViewButtonActivated
    ) {
      model.action()
    }
    .buttonStyle(.designSystem(.titleOnly(.sizeToFit)))
  }

  private var faqSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(L10n.Localizable.mobileVpnPageFaqTitle)
        .textCase(.uppercase)
        .font(.footnote)
        .foregroundStyle(Color.ds.text.neutral.quiet)
        .accessibility(addTraits: .isHeader)

      FAQView(items: [
        FAQItem.makeVPNGeneralItem,
        FAQItem.makeFaqHotspotDetails,
        FAQItem.makeVPNSupportItem,
      ]) { _ in }
    }
  }

  private func copy(_ value: String, fieldType: DetailFieldType) {
    model.copy(value, fieldType: fieldType)
    #if os(iOS)
      UINotificationFeedbackGenerator().notificationOccurred(.success)
    #endif
    toast(fieldType.definitionField.pasteboardMessage, image: .ds.action.copy.outlined)
  }
}

struct VPNMainView_Previews: PreviewProvider {

  static var previews: some View {
    VPNMainView(model: VPNMainViewModel.mock(mode: .activationNeeded))
    VPNMainView(
      model: VPNMainViewModel.mock(
        mode: .activated, credential: PersonalDataMock.Credentials.github))
  }
}

extension Credential {
  fileprivate init(url: PersonalDataURL) {
    self.init()
    self.url = url
  }
}
