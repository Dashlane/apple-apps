import CoreLocalization
import CoreSession
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct LimitedNumberOfDeviceView: View {
  public enum Action {
    case unlink
    case upgrade
    case logout
  }

  let mode: DeviceUnlinker.UnlinkMode
  let action: (Action) -> Void

  public init(
    mode: DeviceUnlinker.UnlinkMode,
    action: @escaping (Action) -> Void
  ) {
    self.mode = mode
    self.action = action
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 21) {
      header
        .frame(maxHeight: .infinity, alignment: .center)
      actions
    }
    .padding(26)
    .loginAppearance()
    #if canImport(UIKit)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          NavigationBarButton(L10n.Core.kwLogOut, action: logout)
        }
      }
    #endif
  }

  private var header: some View {
    VStack(alignment: .center, spacing: 13) {
      VStack(spacing: 10) {
        Image(asset: Asset.multidevices)

        Text(mode.title)
          .font(DashlaneFont.custom(26, .bold).font)
          .fixedSize(horizontal: false, vertical: true)
      }

      Text(mode.description)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)

      if case DeviceUnlinker.UnlinkMode.multiple = mode {
        Infobox(L10n.Core.deviceUnlinkUnlinkDevicePremiumFeatureDescription)
      }
    }
    .multilineTextAlignment(.center)
  }

  private var actions: some View {
    VStack(alignment: .center, spacing: 5) {
      Button(L10n.Core.deviceUnlinkingLimitedPremiumCta, action: upgrade)
      Button(mode.unlinkButtonLabel, action: unlink)
        .style(mood: .brand, intensity: .quiet)

    }
    .buttonStyle(.designSystem(.titleOnly))
  }

  private func upgrade() {
    action(.upgrade)
  }

  private func unlink() {
    action(.unlink)
  }

  private func logout() {
    action(.logout)
  }
}

extension DeviceUnlinker.UnlinkMode {
  fileprivate var title: String {
    switch self {
    case .monobucket:
      return L10n.Core.deviceUnlinkingLimitedTitle
    case let .multiple(limit):
      return L10n.Core.deviceUnlinkLimitedMultiDevicesTitle(limit)
    }
  }

  fileprivate var description: String {
    switch self {
    case .monobucket:
      return L10n.Core.deviceUnlinkingLimitedDescription
    case .multiple:
      return L10n.Core.deviceUnlinkLimitedMultiDevicesDescription
    }
  }

  fileprivate var unlinkButtonLabel: String {
    switch self {
    case .monobucket:
      return L10n.Core.deviceUnlinkingLimitedUnlinkCta
    case .multiple:
      return L10n.Core.deviceUnlinkLimitedMultiDevicesUnlinkCta
    }
  }

}

#Preview("1 device plan") {
  NavigationView {
    LimitedNumberOfDeviceView(mode: .monobucket) { _ in
    }
  }
}

#Preview("2 devices plan") {
  NavigationView {
    LimitedNumberOfDeviceView(mode: .multiple(2)) { _ in
    }
  }
}
