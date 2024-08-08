#if canImport(UIKit)

  import Foundation
  import CorePremium
  import SwiftUI
  import UIDelight
  import CoreLocalization
  import UIComponents
  import DesignSystem
  import DashlaneAPI

  struct PlanCapabilitiesView: View {
    private struct Row: View {
      let text: String
      init(_ text: String) {
        self.text = text
      }

      var body: some View {
        FeatureLine(
          feature: .init(asset: Asset.checkmarkOutlinedStroke.swiftUIImage, description: text),
          size: .small)
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
        Row(L10n.Core.benefitIndividualAcount)
      case .family:
        Row(L10n.Core.planScreensPremiumFamilyAccounts)
      default:
        EmptyView()
      }
    }

    @ViewBuilder
    private var capabilityRows: some View {
      Row(L10n.Core.benefitStorePasswords(forLimit: capabilities.passwordsLimit?.info?.limit))

      if capabilities.devicesLimit?.enabled == true {
        if let limit = capabilities.devicesLimit?.info?.limit {
          Row(L10n.Core.benefitLimitedDevice(forLimit: limit))
        }
      } else {
        Row(L10n.Core.benefitUnlimitedDevices)
      }

      Row(L10n.Core.benefitAutofill)

      if capabilities.dataLeak?.enabled == true && capabilities.securityBreach?.enabled == true {
        Row(L10n.Core.benefitSecurityAlertsAdvanced)
      } else if capabilities.securityBreach?.enabled == true {
        Row(L10n.Core.benefitSecurityAlertsBasic)
      }

      if capabilities.secureWiFi?.enabled == true {
        if kind == .family {
          Row(L10n.Core.benefitVpnFamily)
        } else {
          Row(L10n.Core.benefitVpn)
        }
      }

      if capabilities.secureFiles?.enabled == true,
        let max = capabilities.secureFiles?.info?.quota?.max
      {
        let sizeInGb = Int(max / 1_073_741_824)
        Row(L10n.Core.benefitSecureFiles(sizeInGb))

      }

      Row(L10n.Core.benefitPasswordSharing(forLimit: capabilities.sharingLimit?.info?.limit))

      if capabilities.yubikey?.enabled == true {
        Row(L10n.Core.benefit2faAdvanced)
      } else {
        Row(L10n.Core.benefit2faBasic)
      }

      if capabilities.secureNotes?.enabled == true {
        Row(L10n.Core.benefitSecureNotes)
      }

      Group {
        Row(L10n.Core.benefitPasswordGenerator)
      }

    }

  }

  struct PlanCapabilitiesView_Previews: PreviewProvider {
    static var previews: some View {
      MultiContextPreview {
        PlanCapabilitiesView(
          kind: .family,
          capabilities: PaymentsAccessibleStoreOffersCapabilities(sync: .init(enabled: false))
        )
        .background(.ds.background.alternate)
        PlanCapabilitiesView(
          kind: .family,
          capabilities: PaymentsAccessibleStoreOffersCapabilities(sync: .init(enabled: false))
        )
        .frame(height: 60)
        .background(.ds.background.alternate)
      }.previewLayout(.sizeThatFits)
    }
  }

  extension L10n.Core {

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
#endif
