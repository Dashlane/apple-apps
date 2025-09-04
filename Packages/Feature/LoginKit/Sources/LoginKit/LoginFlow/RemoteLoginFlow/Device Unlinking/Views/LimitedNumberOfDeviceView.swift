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
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(CoreL10n.kwLogOut, action: logout)
      }
    }
  }

  private var header: some View {
    VStack(alignment: .center, spacing: 13) {
      VStack(spacing: 14) {
        Image(.multidevices)

        Text(mode.title)
          .textStyle(.title.section.large)
          .fixedSize(horizontal: false, vertical: true)
      }

      Text(mode.description)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)

      if case DeviceUnlinker.UnlinkMode.multiple = mode {
        Infobox(CoreL10n.deviceUnlinkUnlinkDevicePremiumFeatureDescription)
      }
    }
    .multilineTextAlignment(.center)
  }

  private var actions: some View {
    VStack(alignment: .center, spacing: 5) {
      Button(CoreL10n.deviceUnlinkingLimitedPremiumCta, action: upgrade)
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
      return CoreL10n.deviceUnlinkingLimitedTitle
    case let .multiple(limit):
      return CoreL10n.deviceUnlinkLimitedMultiDevicesTitle(limit)
    }
  }

  fileprivate var description: String {
    switch self {
    case .monobucket:
      return CoreL10n.deviceUnlinkingLimitedDescription
    case .multiple:
      return CoreL10n.deviceUnlinkLimitedMultiDevicesDescription
    }
  }

  fileprivate var unlinkButtonLabel: String {
    switch self {
    case .monobucket:
      return CoreL10n.deviceUnlinkingLimitedUnlinkCta
    case .multiple:
      return CoreL10n.deviceUnlinkLimitedMultiDevicesUnlinkCta
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
