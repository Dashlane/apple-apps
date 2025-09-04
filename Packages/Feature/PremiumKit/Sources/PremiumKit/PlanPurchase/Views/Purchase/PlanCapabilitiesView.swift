import CoreLocalization
import CorePremium
import DashlaneAPI
import DesignSystem
import Foundation
import SwiftUI
import UIComponents
import UIDelight

struct PlanCapabilitiesView: View {
  private struct Row: View {
    let text: String
    init(_ text: String) {
      self.text = text
    }

    var body: some View {
      FeatureLine(feature: .init(asset: .ds.checkmark.outlined, description: text), size: .small)
    }
  }

  let kind: PurchasePlan.Kind
  let capabilities: PaymentsAccessibleStoreOffersCapabilities

  private let overlayGradient = Gradient(colors: [
    .ds.background.alternate,
    .ds.background.alternate.opacity(0),
  ])

  @ViewBuilder
  var body: some View {
    ScrollView {
      VStack {
        kindRow
        capabilityRows
      }
    }
    .overlay(
      LinearGradient(gradient: overlayGradient, startPoint: .bottom, endPoint: .top)
        .frame(height: 10),
      alignment: .bottom
    )
    .fiberAccessibilityElement(children: .combine)
  }

  @ViewBuilder
  private var kindRow: some View {
    switch kind {
    case .premium, .essentials, .advanced:
      Row(CoreL10n.benefitIndividualAcount)
    case .family:
      Row(CoreL10n.planScreensPremiumFamilyAccounts)
    default:
      EmptyView()
    }
  }

  @ViewBuilder
  private var capabilityRows: some View {
    Row(CoreL10n.benefitStorePasswords(forLimit: capabilities.passwordsLimit?.info?.limit))

    if capabilities.devicesLimit?.enabled == true {
      if let limit = capabilities.devicesLimit?.info?.limit {
        Row(CoreL10n.benefitLimitedDevice(forLimit: limit))
      }
    } else {
      Row(CoreL10n.benefitUnlimitedDevices)
    }

    Row(CoreL10n.benefitAutofill)

    if capabilities.dataLeak?.enabled == true && capabilities.securityBreach?.enabled == true {
      Row(CoreL10n.benefitSecurityAlertsAdvanced)
    } else if capabilities.securityBreach?.enabled == true {
      Row(CoreL10n.benefitSecurityAlertsBasic)
    }

    if capabilities.secureWiFi?.enabled == true {
      if kind == .family {
        Row(CoreL10n.benefitVpnFamily)
      } else {
        Row(CoreL10n.benefitVpn)
      }
    }

    if capabilities.secureFiles?.enabled == true,
      let max = capabilities.secureFiles?.info?.quota?.max
    {
      let sizeInGb = Int(max / 1_073_741_824)
      Row(CoreL10n.benefitSecureFiles(sizeInGb))

    }

    Row(CoreL10n.benefitPasswordSharing(forLimit: capabilities.sharingLimit?.info?.limit))

    if capabilities.yubikey?.enabled == true {
      Row(CoreL10n.benefit2faAdvanced)
    } else {
      Row(CoreL10n.benefit2faBasic)
    }

    if capabilities.secureNotes?.enabled == true {
      Row(CoreL10n.benefitSecureNotes)
    }

    Group {
      Row(CoreL10n.benefitPasswordGenerator)
    }

  }

}

#Preview("Default Size", traits: .sizeThatFitsLayout) {
  PlanCapabilitiesView(
    kind: .family,
    capabilities: PaymentsAccessibleStoreOffersCapabilities(sync: .init(enabled: false))
  )
  .background(.ds.background.alternate)
}

#Preview("Fixed Height", traits: .sizeThatFitsLayout) {
  PlanCapabilitiesView(
    kind: .family,
    capabilities: PaymentsAccessibleStoreOffersCapabilities(sync: .init(enabled: false))
  )
  .frame(height: 60)
  .background(.ds.background.alternate)
}

extension CoreL10n {

  fileprivate static func benefitStorePasswords(forLimit limit: Int?) -> String {
    if let limit = limit {
      return benefitStorePasswordsLimited(limit)
    } else {
      return benefitStorePasswordsUnlimited
    }
  }

  fileprivate static func benefitLimitedDevice(forLimit limit: Int) -> String {
    if limit < 2 {
      return benefitLimitedDeviceOne(limit)
    } else {
      return benefitLimitedDeviceSome(limit)
    }
  }

  fileprivate static func benefitPasswordSharing(forLimit limit: Int?) -> String {
    if let limit = limit {
      return benefitPasswordSharingLimited(limit)
    } else {
      return benefitPasswordSharingUnlimited
    }
  }
}
