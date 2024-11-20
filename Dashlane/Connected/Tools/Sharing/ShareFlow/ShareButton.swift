import CoreLocalization
import SwiftUI
import VaultKit

struct ShareButton<Label: View>: View {
  let model: ShareButtonViewModel

  @ViewBuilder
  let label: Label

  @State
  var showDisabledAlert: Bool = false

  @State
  var showFlow: Bool = false

  var body: some View {
    Button {
      if model.deactivationReason != nil {
        showDisabledAlert = true
      } else {
        showFlow = true
      }
    } label: {
      label
    }
    .accessibilityLabel(L10n.Localizable.kwShareItem)
    .alert(
      L10n.Localizable.teamSpacesSharingDisabledMessageTitle,
      isPresented: $showDisabledAlert,
      actions: {
        Button(CoreLocalization.L10n.Core.kwButtonOk) {}
      },
      message: {
        if let message = model.deactivationReason?.message {
          Text(message)
        }
      }
    )
    .sheet(isPresented: $showFlow) {
      ShareFlowView(model: model.makeShareFlowViewModel())
    }
  }
}

extension SharingDeactivationReason {
  var message: String {
    switch self {
    case .b2bSharingDisabled:
      return L10n.Localizable.teamSpacesSharingDisabledMessageBody
    case .frozenAccount:
      return CoreLocalization.L10n.Core.notificationFrozenAccountTitle
    }
  }
}

struct ShareButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ShareButton(model: .mock()) {
        Text("Full Flow Button")
      }
      ShareButton(model: .mock(items: [PersonalDataMock.Credentials.amazon])) {
        Text("Share one item")
      }
    }

  }
}
