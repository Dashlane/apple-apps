import SwiftUI
import CoreSession
import UIDelight
import UIComponents
import DesignSystem
import CoreLocalization

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

    public init(limit: Int,
                devices: [DeviceListEntry],
                action: @escaping (Action) -> Void) {
        self.limit = limit
        self.devices = devices
        self.action = action
    }

    @State
    private var selectedDevices: Set<DeviceListEntry> = []

    @State
    private var listHeight: CGFloat?

        private var canUnlink: Bool {
        (devices.count - selectedDevices.count) < limit 
    }

        public var body: some View {
        VStack(alignment: .leading, spacing: 21) {
            ScrollView(.vertical, showsIndicators: false) {
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
        VStack(alignment: .leading, spacing: 2) {
            Text(L10n.Core.deviceUnlinkUnlinkDevicesTitle)
                .font(DashlaneFont.custom(26, .bold).font)

            Text(L10n.Core.deviceUnlinkUnlinkDevicesSubtitle)
                .font(.body)
                .foregroundColor(.ds.text.neutral.standard)
        }
    }

    private var list: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.Core.deviceUnlinkLimitedMultiDevicesDescription)
                .font(.caption)
                .foregroundColor(.ds.text.neutral.standard)
            ScrollViewReader { scrollReader in
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(devices) { device in
                            SelectionDeviceRow(device: device.displayedDevice, isSelected: selectedDevices.contains(device))
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
                    .onSizeChange(onListSizeChange)
                }
            }
            .cornerRadius(4.0)
            .overlay(RoundedRectangle(cornerRadius: 4.0)
                        .stroke(lineWidth: 1.0)
                        .foregroundColor(Color.secondary)
                        .opacity(0.17))
            .frame(maxHeight: listHeight)
            Spacer()
        }
    }

    private func onListSizeChange(_ size: CGSize) {
        guard size.height != 0 else {
            return
        }
        self.listHeight = size.height
    }

    private var actions: some View {
        VStack(alignment: .center, spacing: 5) {
            RoundedButton(L10n.Core.deviceUnlinkingUnlinkCta, action: unlink)
                .roundedButtonLayout(.fill)
            .disabled(!canUnlink)

            Button(action: upgrade) {
                Text(L10n.Core.deviceUnlinkUnlinkDevicesUpgradeCta)
                    .foregroundColor(.ds.text.brand.standard)
            }
            .buttonStyle(BorderlessActionButtonStyle())
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
              let nextDevice = devices[selectedIndex...].first(where: { !selectedDevices.contains($0) }) else {
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
        SelectionRow(isSelected: isSelected, spacing: 20) {
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

struct SelectionDeviceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.overlay(Group {
            if configuration.isPressed {
                Color.ds.container.expressive.brand.quiet.idle.opacity(0.6)
            }
        })
    }
}

struct UnlinkMutltiDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            SelectionDeviceRow(device: BucketDevice(id: "id",
                                                    name: "mac mini m2x",
                                                    platform: .macos,
                                                    creationDate: Date(),
                                                    lastUpdateDate: Date(),
                                                    lastActivityDate: Date().addingTimeInterval(-5000),
                                                    isBucketOwner: false,
                                                    isTemporary: false),
                               isSelected: true

            )
            .background(.ds.background.default)
            .previewLayout(.sizeThatFits)

            UnlinkMutltiDevicesView(
                limit: 2,
                devices: [
                    BucketDevice(id: "id",
                                 name: "iPhone",
                                 platform: .iphone,
                                 creationDate: Date(),
                                 lastUpdateDate: Date(),
                                 lastActivityDate: Date().addingTimeInterval(-300),
                                 isBucketOwner: false,
                                 isTemporary: false),
                    BucketDevice(id: "idPixel",
                                 name: "Unsafe Device",
                                 platform: .android,
                                 creationDate: Date(),
                                 lastUpdateDate: Date(),
                                 lastActivityDate: Date().addingTimeInterval(-990000),
                                 isBucketOwner: false,
                                 isTemporary: false),
                    BucketDevice(id: "idWin",
                                 name: "Windobe",
                                 platform: .windows,
                                 creationDate: Date(),
                                 lastUpdateDate: Date(),
                                 lastActivityDate: Date().addingTimeInterval(-990000),
                                 isBucketOwner: false,
                                 isTemporary: false),
                    BucketDevice(id: "idWeb",
                                 name: "Slow Web",
                                 platform: .web,
                                 creationDate: Date(),
                                 lastUpdateDate: Date(),
                                 lastActivityDate: Date().addingTimeInterval(-1990000),
                                 isBucketOwner: false,
                                 isTemporary: false),
                    BucketDevice(id: "ids",
                                 name: "iPhone",
                                 platform: .iphone,
                                 creationDate: Date(),
                                 lastUpdateDate: Date(),
                                 lastActivityDate: Date().addingTimeInterval(-300),
                                 isBucketOwner: false,
                                 isTemporary: false),
                    BucketDevice(id: "idPixesl",
                                 name: "Unsafe Device",
                                 platform: .android,
                                 creationDate: Date(),
                                 lastUpdateDate: Date(),
                                 lastActivityDate: Date().addingTimeInterval(-990000),
                                 isBucketOwner: false,
                                 isTemporary: false),
                    BucketDevice(id: "idWisn",
                                 name: "Windobe",
                                 platform: .windows,
                                 creationDate: Date(),
                                 lastUpdateDate: Date(),
                                 lastActivityDate: Date().addingTimeInterval(-990000),
                                 isBucketOwner: false,
                                 isTemporary: false),
                    BucketDevice(id: "idWesb",
                                 name: "Slow Web",
                                 platform: .web,
                                 creationDate: Date(),
                                 lastUpdateDate: Date(),
                                 lastActivityDate: Date().addingTimeInterval(-1990000),
                                 isBucketOwner: false,
                                 isTemporary: false)

                ].map { .independentDevice($0) }) { _ in

            }
        }
    }
}
