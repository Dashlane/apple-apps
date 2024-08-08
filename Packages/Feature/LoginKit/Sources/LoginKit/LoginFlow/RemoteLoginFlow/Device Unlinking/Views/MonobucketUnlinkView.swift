import CoreLocalization
import CoreSession
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct MonobucketUnlinkView: View {
  public enum Action {
    case unlink
    case cancel
  }

  let device: BucketDevice
  let action: (Action) -> Void

  @Environment(\.dismiss)
  private var dismiss

  public init(
    device: BucketDevice,
    action: @escaping (Action) -> Void
  ) {
    self.device = device
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
          NavigationBarButton(L10n.Core.cancel, action: cancel)
        }
      }
    #endif
  }

  private var header: some View {
    VStack(alignment: .center, spacing: 24) {

      Text(L10n.Core.deviceUnlinkingUnlinkTitle)
        .font(DashlaneFont.custom(26, .bold).font)
      VStack(alignment: .center, spacing: 8) {
        Divider()
        BucketDeviceRow(device: device)
        Divider()
      }
      Text(L10n.Core.deviceUnlinkingUnlinkDescription)
        .font(.body)
        .foregroundColor(.ds.text.neutral.standard)

    }.multilineTextAlignment(.center)
  }

  private var actions: some View {
    VStack(alignment: .center, spacing: 5) {
      Button(L10n.Core.deviceUnlinkingUnlinkCta, action: unlink)
        .buttonStyle(.designSystem(.titleOnly))
    }
  }

  private func unlink() {
    action(.unlink)
  }

  private func cancel() {
    action(.cancel)
    dismiss()
  }
}

struct MonobucketUnlinkView_Previews: PreviewProvider {
  static let device = BucketDevice(
    id: "id",
    name: "mac mini m2x",
    platform: .macos,
    creationDate: Date(),
    lastUpdateDate: Date(),
    lastActivityDate: Date().addingTimeInterval(-5000),
    isBucketOwner: false,
    isTemporary: false)
  static var previews: some View {
    MultiContextPreview {
      MonobucketUnlinkView(device: device) { _ in

      }
      MonobucketUnlinkView(device: device) { _ in

      }
    }
  }
}
