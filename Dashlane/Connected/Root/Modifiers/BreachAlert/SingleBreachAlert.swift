import CorePremium
import DesignSystemExtra
import SecurityDashboard
import SwiftUI

struct SingleBreachAlert: View {
  let popupAlert: PopupAlert
  let action: (AlertButton) -> Void

  var body: some View {
    NativeAlert {
      VStack(alignment: .leading, spacing: 0) {
        Text(popupAlert.title)
          .font(.body.bold())

        Text(popupAlert.message)
      }
      .padding(16)

    } buttons: {
      if let second = popupAlert.alert.buttons.left {
        Button(second) {
          action(second)
        }
      }

      if let main = popupAlert.alert.buttons.right {
        Button(main) {
          action(main)
        }
      }
    }
  }
}

extension Button<Text> {
  fileprivate init(_ alertButton: AlertButton, action: @escaping () -> Void) {
    let role: ButtonRole? =
      switch alertButton {
      case .cancel, .close, .later, .dismiss:
        .cancel
      default:
        nil
      }

    self.init(alertButton.localized, role: role, action: action)
  }
}

extension AlertButton {
  fileprivate var localized: String {
    switch self {
    case .cancel:
      return IdentityDashboardLocalizationProvider().localizedString(for: .popupCancelCTA)
    case .close:
      return IdentityDashboardLocalizationProvider().localizedString(for: .popupCloseCTA)
    case .later:
      return IdentityDashboardLocalizationProvider().localizedString(for: .popupLaterCTA)
    case .view:
      return IdentityDashboardLocalizationProvider().localizedString(for: .popupViewCTA)
    case .upgrade:
      return IdentityDashboardLocalizationProvider().localizedString(for: .popupUpgradeCTA)
    case .takeAction:
      return IdentityDashboardLocalizationProvider().localizedString(for: .popupTakeActionCTA)
    case .dismiss:
      return IdentityDashboardLocalizationProvider().localizedString(for: .popupDismissCTA)
    case .viewDetails:
      return IdentityDashboardLocalizationProvider().localizedString(for: .popupViewDetailsCTA)
    }
  }
}

#Preview {
  SingleBreachAlert(popupAlert: .init(.mock)) { _ in

  }
}
