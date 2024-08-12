import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents

struct AutofillErrorView: View {
  let error: AutofillError

  enum Action {
    case cancel
  }

  @Environment(\.openURL)
  private var openURL

  let action: (Action) -> Void

  var body: some View {
    NavigationView {
      VStack(spacing: 40) {
        Image(asset: FiberAsset.logomark)
          .fiberAccessibilityHidden(true)
        VStack(spacing: 20) {
          Text(L10n.Localizable.tachyonLoginRequiredScreenTitle)
            .foregroundColor(.ds.text.neutral.catchy)
            .multilineTextAlignment(.center)
            .font(DashlaneFont.custom(26, .bold).font)
            .accessibilitySortPriority(2)

          Text(error.title)
            .foregroundColor(.ds.text.neutral.standard)
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .contain)

        Button {
          handleAction()
        } label: {
          Text(error.actionTitle)
            .foregroundColor(.ds.text.brand.standard)
        }
      }
      .padding(.horizontal, 24)
      .frame(maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        Text("Code: \(error.code)")
          .font(.footnote)
          .foregroundColor(.ds.text.neutral.quiet)
      }
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            action(.cancel)
          } label: {
            Text(CoreLocalization.L10n.Core.cancel)
              .foregroundColor(.ds.text.brand.standard)
          }
        }
      }
    }
  }

  private func handleAction() {
    switch error {
    case .noUserConnected: goToMainApp()
    case .ssoUserWithNoConvenientLoginMethod: goToSecuritySettings()
    }
  }

  private func goToMainApp() {
    openURL(URL(string: "dashlane:///")!)
  }

  private func goToSecuritySettings() {
    openURL(URL(string: "dashlane:///settings/security")!)
  }
}

struct AutofillErrorView_Previews: PreviewProvider {

  static var previews: some View {
    AutofillErrorView(error: .ssoUserWithNoConvenientLoginMethod) { _ in

    }
  }
}
