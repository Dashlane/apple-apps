import Foundation
import SwiftUI

public struct CustomPreviewDevice: Identifiable, Hashable {
    public var id: String {
        "\(displayName)-\(deviceName)-\(interfaceOrientation.id)"
    }

    let deviceName: String
    let displayName: String
    let interfaceOrientation: InterfaceOrientation
    
    public init(
        deviceName: String,
        displayName: String,
        interfaceOrientation: InterfaceOrientation = .portrait
    ) {
        self.deviceName = deviceName
        self.displayName = displayName
        self.interfaceOrientation = interfaceOrientation
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func interfaceOrientation(_ interfaceOrientation: InterfaceOrientation) -> CustomPreviewDevice {
        .init(
            deviceName: deviceName,
            displayName: displayName,
            interfaceOrientation: interfaceOrientation
        )
    }
    
    public func displayName(_ displayName: String) -> CustomPreviewDevice {
        .init(
            deviceName: deviceName,
            displayName: displayName,
            interfaceOrientation: interfaceOrientation
        )
    }
    
    public enum iPhone {
        public static let small = CustomPreviewDevice(
            deviceName: "iPhone SE (3rd generation)",
            displayName: "Small iPhone"
        )
        public static let regular = CustomPreviewDevice(
            deviceName: "iPhone 14 Pro",
            displayName: "Regular iPhone"
        )
        public static let large = CustomPreviewDevice(
            deviceName: "iPhone 14 Pro Max",
            displayName: "Large iPhone"
        )
    }
    
    public enum iPad {
        public static let mini = CustomPreviewDevice(
            deviceName: "iPad mini (6th generation)",
            displayName: "iPad mini"
        )
    }
}

public struct MultiDevicesPreview<Content: View>: View {
    private let content: Content
    private let devices: [CustomPreviewDevice]
    
    public init(devices: [CustomPreviewDevice], content: @escaping () -> Content) {
        self.devices = devices
        self.content = content()
    }
    
    public init(content: @escaping () -> Content) {
        self.devices = Self.makeDefaultDevices()
        self.content = content()
    }
    
    public var body: some View {
        ForEach(devices, id: \.self) { device in
            content
                .previewDevice(PreviewDevice(rawValue: device.deviceName))
                .previewDisplayName(device.displayName)
                .previewInterfaceOrientation(device.interfaceOrientation)
        }
    }
    
    private static func makeDefaultDevices() -> [CustomPreviewDevice] {
        [
            .iPhone.regular,
            .iPhone.small,
            .iPhone.large,
            .iPad.mini,
            .iPad.mini
                .interfaceOrientation(.landscapeRight)
                .displayName("iPad mini Landscape")
        ]
    }
}
