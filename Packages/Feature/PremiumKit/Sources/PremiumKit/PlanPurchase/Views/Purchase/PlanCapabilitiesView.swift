#if canImport(UIKit)

import Foundation
import CorePremium
import SwiftUI
import UIDelight
import CoreLocalization
import UIComponents
import DesignSystem

struct PlanCapabilitiesView: View {
    private struct Row: View {
        let text: String
        init(_ text: String) {
            self.text = text
        }

        var body: some View {
            HStack {
                Image(asset: Asset.checkmarkOutlinedStroke)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .foregroundColor(.ds.text.neutral.catchy)
                    .fiberAccessibilityHidden(true)
                MarkdownText(text)
                    .font(.body)
                    .foregroundColor(.ds.text.neutral.standard)
                Spacer()
            }
        }
    }

    let kind: PurchasePlan.Kind
    let set: CapabilitySet

    private let overlayGradient = Gradient(colors: [
        .ds.background.alternate,
        .ds.background.alternate.opacity(0)
    ])

    @ViewBuilder
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                kindRow
                capabilityRows
            }
        }
        .overlay(LinearGradient(gradient: overlayGradient, startPoint: .top, endPoint: .bottom)
                    .frame(height: 10),
                  alignment: .top)
        .overlay(LinearGradient(gradient: overlayGradient, startPoint: .bottom, endPoint: .top)
                    .frame(height: 10),
                 alignment: .bottom)
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
        Row(L10n.Core.benefitStorePasswords(forLimit: set.passwordsLimit.info?.limit))

        if set.devicesLimit.enabled {
            if let limit = set.devicesLimit.info?.limit {
                Row(L10n.Core.benefitLimitedDevice(forLimit: limit))
            }
        } else {
            Row(L10n.Core.benefitUnlimitedDevices)
        }

                Row(L10n.Core.benefitAutofill)

        if set.dataLeak.enabled && set.securityBreach.enabled {
            Row(L10n.Core.benefitSecurityAlertsAdvanced)
        } else if set.securityBreach.enabled == true {
            Row(L10n.Core.benefitSecurityAlertsBasic)
        }

        if set.secureWiFi.enabled {
            Row(L10n.Core.benefitVpn)
        }

        if set.secureFiles.enabled,
           let max = set.secureFiles.info?.quota.max {
            let sizeInGb = Int(max / 1073741824) 
            Row(L10n.Core.benefitSecureFiles(sizeInGb))

        }

        Row(L10n.Core.benefitPasswordSharing(forLimit: set.sharingLimit.info?.limit))

        if set.yubikey.enabled {
            Row(L10n.Core.benefit2faAdvanced)
        } else {
            Row(L10n.Core.benefit2faBasic)
        }

        if set.secureNotes.enabled {
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
            PlanCapabilitiesView(kind: .family, set: OfferCapabilitySet(sync: .init(enabled: false)))
                .background(.ds.background.alternate)
            PlanCapabilitiesView(kind: .family, set: OfferCapabilitySet(sync: .init(enabled: false)))
                .frame(height: 60)
                .background(.ds.background.alternate)
        }.previewLayout(.sizeThatFits)
    }
}

private extension L10n.Core {

    static func benefitStorePasswords(forLimit limit: Int?) -> String {
        if let limit = limit {
            return benefitStorePasswordsLimited(limit)
        } else {
            return benefitStorePasswordsUnlimited
        }
    }

    static func benefitLimitedDevice(forLimit limit: Int) -> String {
        if limit < 2 {
            return benefitLimitedDeviceOne(limit)
        } else {
            return benefitLimitedDeviceSome(limit)
        }
    }

    static func benefitPasswordSharing(forLimit limit: Int?) -> String {
        if let limit = limit {
            return benefitPasswordSharingLimited(limit)
        } else {
            return benefitPasswordSharingUnlimited
        }
    }
}
#endif
