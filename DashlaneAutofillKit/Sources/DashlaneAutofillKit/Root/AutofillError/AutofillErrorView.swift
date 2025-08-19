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
        Image(.logomark)
          .fiberAccessibilityHidden(true)
        VStack(spacing: 20) {
          Text(L10n.Localizable.tachyonLoginRequiredScreenTitle)
            .foregroundStyle(Color.ds.text.neutral.catchy)
            .multilineTextAlignment(.center)
            .textStyle(.title.section.large)
            .accessibilitySortPriority(2)

          Text(error.title)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .contain)

        Button {
          handleAction()
        } label: {
          Text(error.actionTitle)
            .foregroundStyle(Color.ds.text.brand.standard)
        }
      }
      .padding(.horizontal, 24)
      .frame(maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        Text("Code: \(error.code)")
          .font(.footnote)
          .foregroundStyle(Color.ds.text.neutral.quiet)
      }
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            action(.cancel)
          } label: {
            Text(CoreL10n.cancel)
              .foregroundStyle(Color.ds.text.brand.standard)
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
