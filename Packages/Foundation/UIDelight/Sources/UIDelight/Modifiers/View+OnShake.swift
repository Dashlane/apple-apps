import SwiftUI
#if canImport(UIKit)
import UIKit

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}
#endif

public extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        #if canImport(UIKit)
        self.modifier(DeviceShakeViewModifier(action: action))
        #else
        self
        #endif
    }
}
