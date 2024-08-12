import Foundation
import SwiftTreats
import SwiftUI

#if canImport(UIKit)
  extension View {

    public func onApplicationResignation(completion: @escaping () -> Void) -> some View {
      self.onReceive(
        NotificationCenter.default.publisher(
          for: UIApplication.applicationWillResignActiveNotification)
      ) { _ in
        completion()
      }
    }

    public func onApplicationActivation(completion: @escaping () -> Void) -> some View {
      self.onReceive(
        NotificationCenter.default.publisher(
          for: UIApplication.applicationWillEnterForegroundNotification)
      ) { _ in
        completion()
      }
    }

  }
#endif
