import CoreLocalization
import CoreSession
import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIComponents
import UIDelight

public struct UnlinkMutltiDevicesView: View {
  public enum Action {
    case upgrade(Set<DeviceListEntry>)
    case unlink(Set<DeviceListEntry>)
    case cancel
  }

  let limit: Int
  let devices: [DeviceListEntry]
  let action: (Action) -> Void

  @Environment(\.dismiss)
  private var dismiss

  public init(
    limit: Int,
    devices: [DeviceListEntry],
    action: @escaping (Action) -> Void
  ) {
    self.limit = limit
    self.devices = devices
    self.action = action
  }

  @State
  private var selectedDevices: Set<DeviceListEntry> = []

  private var canUnlink: Bool {
    (devices.count - selectedDevices.count) < limit
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 21) {
      VStack(spacing: 4) {
        HStack {
          header
          Spacer()
        }
        list
      }
      actions
    }
    .padding(26)
    .loginAppearance()
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(CoreL10n.cancel, action: cancel)
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(CoreL10n.deviceUnlinkUnlinkDevicesTitle)
        .textStyle(.title.section.medium)

      Text(CoreL10n.deviceUnlinkUnlinkDevicesSubtitle)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
    }
  }

  private var list: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text(CoreL10n.deviceUnlinkLimitedMultiDevicesDescription)
        .textStyle(.body.helper.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
      ScrollViewReader { scrollReader in
        ScrollView(.vertical) {
          LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(devices) { device in
              SelectionDeviceRow(
                device: device.displayedDevice, isSelected: selectedDevices.contains(device)
              )
              .onTapWithFeedback {
                toggle(device)
                scrollToUnselected(nextTo: device, using: scrollReader)
              }
              .buttonStyle(SelectionDeviceButtonStyle())

              if device != devices.last {
                Divider()
              }
            }
          }
        }
        .scrollIndicators(.visible)
      }
      .cornerRadius(4.0)
      .overlay(
        RoundedRectangle(cornerRadius: 4.0)
          .stroke(lineWidth: 1.0)
          .foregroundStyle(.secondary)
          .opacity(0.17)
      )
    }
  }

  private var actions: some View {
    VStack(alignment: .center, spacing: 5) {
      Button(CoreL10n.deviceUnlinkingUnlinkCta, action: unlink)
        .buttonStyle(.designSystem(.titleOnly))
        .disabled(!canUnlink)

      Button(action: upgrade) {
        Text(CoreL10n.deviceUnlinkUnlinkDevicesUpgradeCta)
          .foregroundStyle(Color.ds.text.brand.standard)
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(intensity: .supershy)
    }
  }

  private func toggle(_ device: DeviceListEntry) {
    if selectedDevices.contains(device) {
      selectedDevices.remove(device)
    } else {
      selectedDevices.insert(device)
    }
  }

  private func scrollToUnselected(nextTo device: DeviceListEntry, using reader: ScrollViewProxy) {
    guard !canUnlink, selectedDevices.contains(device),
      let selectedIndex = devices.firstIndex(of: device),
      let nextDevice = devices[selectedIndex...].first(where: { !selectedDevices.contains($0) })
    else {
      return
    }
    withAnimation {
      reader.scrollTo(nextDevice.id)
    }
  }

  private func unlink() {
    action(.unlink(selectedDevices))
  }

  private func upgrade() {
    action(.upgrade(selectedDevices))
  }

  private func cancel() {
    action(.cancel)
    dismiss()
  }
}

private struct SelectionDeviceRow: View {
  let device: BucketDevice
  let isSelected: Bool

  var body: some View {
    NativeSelectionRow(isSelected: isSelected, spacing: 20) {
      BucketDeviceRow(device: device)
    }
    .padding(16)
    .background(background)
    .animation(.easeInOut, value: isSelected)
  }

  @ViewBuilder
  var background: some View {
    if isSelected {
      Color.ds.container.expressive.brand.quiet.idle.opacity(0.3)
    }
  }
}

private struct SelectionDeviceButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    configuration.label.overlay(
      Group {
        if configuration.isPressed {
          Color.ds.container.expressive.brand.quiet.idle.opacity(0.6)
        }
      }
    )
    .hoverEffect(isEnabled: isEnabled)
  }
}

#if DEBUG

  extension BucketDevice {
    fileprivate static func preview(
      id: String,
      name: String,
      platform: DevicePlatform,
      lastActivityInterval: TimeInterval
    ) -> BucketDevice {
      BucketDevice(
        id: id,
        name: name,
        platform: platform,
        creationDate: Date(),
        lastUpdateDate: Date(),
        lastActivityDate: Date().addingTimeInterval(lastActivityInterval),
        isBucketOwner: false,
        isTemporary: false
      )
    }
  }

  #Preview("SelectionDeviceRow", traits: .sizeThatFitsLayout) {
    SelectionDeviceRow(
      device: BucketDevice(
        id: "id",
        name: "mac mini m2x",
        platform: .macos,
        creationDate: Date(),
        lastUpdateDate: Date(),
        lastActivityDate: Date().addingTimeInterval(-5000),
        isBucketOwner: false,
        isTemporary: false
      ),
      isSelected: true
    )
    .background(.ds.background.default)
  }

  #Preview("UnlinkMutltiDevicesView") {
    let devices: [BucketDevice] = [
      .preview(id: "id", name: "iPhone", platform: .iphone, lastActivityInterval: -300),
      .preview(
        id: "idPixel", name: "Unsafe Device", platform: .android, lastActivityInterval: -990000),
      .preview(id: "idWin", name: "Windobe", platform: .windows, lastActivityInterval: -990000),
      .preview(id: "idWeb", name: "Slow Web", platform: .web, lastActivityInterval: -1_990_000),
      .preview(id: "ids", name: "iPhone", platform: .iphone, lastActivityInterval: -300),
      .preview(
        id: "idPixesl", name: "Unsafe Device", platform: .android, lastActivityInterval: -990000),
      .preview(id: "idWisn", name: "Windobe", platform: .windows, lastActivityInterval: -990000),
      .preview(id: "idWesb", name: "Slow Web", platform: .web, lastActivityInterval: -1_990_000),
    ]

    UnlinkMutltiDevicesView(
      limit: 2,
      devices: devices.map { .independentDevice($0) }
    ) { _ in
    }
  }
#endif
