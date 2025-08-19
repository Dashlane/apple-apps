import CoreTypes
import SwiftUI

struct ChangeSharingPermissionButton: View {
  let currentPermission: SharingPermission
  let action: (SharingPermission) -> Void

  var body: some View {
    Button(L10n.Localizable.changeActionTitle(for: currentPermission)) {
      switch currentPermission {
      case .admin:
        action(.limited)
      case .limited:
        action(.admin)
      }
    }
  }

}

struct ChangeSharingPermissionButton_Previews: PreviewProvider {
  static var previews: some View {
    ChangeSharingPermissionButton(currentPermission: .admin) { _ in

    }
    ChangeSharingPermissionButton(currentPermission: .limited) { _ in

    }
  }
}

extension L10n.Localizable {
  static func changeActionTitle(for permission: SharingPermission) -> String {
    switch permission {
    case .admin:
      return L10n.Localizable.kwRevokeAdminRights
    case .limited:
      return L10n.Localizable.kwGrantAdminRights
    }
  }
}
