import SwiftUI

public struct ToastAction {
    let show: @MainActor (AnyView) -> Void

    public func callAsFunction<Content: View>(_ view: Content) {
        Task {
           await show(AnyView(view))
        }
    }
}

public extension ToastAction {
    func callAsFunction(_ text: String, systemImage: String, accessibilityAnnouncement: String? = nil) {
        self.callAsFunction(ToastLabel(text, accessibilityAnnouncement: accessibilityAnnouncement, systemImage: systemImage))
    }

    func callAsFunction(_ text: String, image: Image? = nil, accessibilityAnnouncement: String? = nil) {
        self.callAsFunction(ToastLabel(text, accessibilityAnnouncement: accessibilityAnnouncement, image: image))
    }

    func callAsFunction(_ text: Text, systemImage: String, accessibilityAnnouncement: String) {
        self.callAsFunction(ToastLabel(text, accessibilityAnnouncement: accessibilityAnnouncement, systemImage: systemImage))
    }

    func callAsFunction(_ text: Text, image: Image? = nil, accessibilityAnnouncement: String) {
        self.callAsFunction(ToastLabel(text, accessibilityAnnouncement: accessibilityAnnouncement, image: image))
    }
}

struct ToastActionKey: EnvironmentKey {
    static var defaultValue: ToastAction = ToastAction { _ in }
}

extension EnvironmentValues {
        public var toast: ToastAction {
         get {
            return self[ToastActionKey.self]
        }
        set {
            self[ToastActionKey.self] = newValue
        }
    }

}
