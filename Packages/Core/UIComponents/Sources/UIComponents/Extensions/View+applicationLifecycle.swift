import Foundation
import SwiftUI
import SwiftTreats

#if canImport(UIKit)
public extension View {

        func onApplicationResignation(completion: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: UIApplication.applicationWillResignActiveNotification)) { _ in
            completion()
        }
    }

        func onApplicationActivation(completion: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: UIApplication.applicationWillEnterForegroundNotification)) { _ in
            completion()
        }
    }

}
#endif
