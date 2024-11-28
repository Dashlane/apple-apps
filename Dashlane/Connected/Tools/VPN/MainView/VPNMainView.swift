import Combine
import CoreLocalization
import CorePersonalData
import DashTypes
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
      case .activationNeeded: activationView
      case .activated: activatedView
      }
    }
    .navigationTitle(L10n.Localizable.mobileVpnTitle)
    .backgroundColorIgnoringSafeArea(.ds.background.alternate)
  }

  private var activationView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        VStack(spacing: 8) {
          titleView
          mainButton
        }

        if !model.hasDismissedNewProviderMessage {
          Infobox(L10n.Localizable.mobileVpnNewProviderInfoboxHeaderTitle) {
            Button(L10n.Localizable.mobileVpnNewProviderInfoboxLearnMore) {
              isPresentingInfoModal = true
            }
            Button(L10n.Localizable.mobileVpnNewProviderInfoboxDismiss) {
              withAnimation { model.dismissNewProviderMessage() }
            }
          }
        }

        faqSection

        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.top, 24)
      .fiberAccessibilityHidden(isPresentingInfoModal)
    }
    .bottomSheet(isPresented: $isPresentingInfoModal) {
      VPNInfoModalView(buttonAction: {
        isPresentingInfoModal = false
        model.dismissNewProviderMessage()
      })
    }
    .reportPageAppearance(.toolsVpn)
  }

  private var activatedView: some View {
    ScrollView {
      VStack {
        titleView

        credentialView.padding(.top, 24)
        mainButton

        Spacer(minLength: 48)
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
          Text("Hotspot Shield").font(.body).fontWeight(.semibold)
          Spacer()
        }
        TextDetailField(
          title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.login,
          text: Binding.constant(credential.email),
          actions: [.copy(copy)]
        )
        .actions([.copy(copy)])
        .fiberFieldType(.email)
        .padding(.top, 26)
        .editionDisabled()

        SecureDetailField(
          title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.password,
          text: Binding.constant(credential.password),
          onRevealAction: { _ in },
          isColored: true,
          actions: [.copy(copy)]
        )
        .actions([.copy(copy)])
        .fiberFieldType(.password)
        .editionDisabled()
      }
      .padding(16)
      .background(Color.ds.container.expressive.neutral.quiet.idle)
      .cornerRadius(8)
    }
  }

  private var titleView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text(model.title)
          .font(.custom(GTWalsheimPro.bold.name, size: 26, relativeTo: .title).weight(.medium))
        Text(model.subtitle)
          .font(.subheadline)
          .foregroundColor(.ds.text.neutral.quiet)
          .padding(.top, 8)
      }
      Spacer()
    }
  }

  private var mainButton: some View {
    Button(model.buttonTitle, action: model.action)
      .buttonStyle(.designSystem(.titleOnly))
      .padding(.top, 24)
  }

  private var faqSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(L10n.Localizable.mobileVpnPageFaqTitle)
        .textCase(.uppercase)
        .font(.footnote)
        .foregroundColor(.ds.text.neutral.quiet)
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
    UINotificationFeedbackGenerator().notificationOccurred(.success)
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
