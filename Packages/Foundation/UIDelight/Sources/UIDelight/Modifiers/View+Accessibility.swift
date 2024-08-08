#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import Combine
  import UIKit

  extension View {

    @ViewBuilder
    public func fiberAccessibilityLabel(_ label: Text) -> some View {
      if ProcessInfo.isTesting {
        self
      } else {
        self.accessibilityLabel(label)
      }
    }

    @ViewBuilder
    public func fiberAccessibilityHint(_ hint: Text) -> some View {
      if ProcessInfo.isTesting {
        self
      } else {
        self.accessibilityHint(hint)
      }
    }

    @ViewBuilder
    public func fiberAccessibilityElement(children: AccessibilityChildBehavior = .ignore)
      -> some View
    {
      if ProcessInfo.isTesting {
        self
      } else {
        self.accessibilityElement(children: children)
      }
    }

    @ViewBuilder
    public func fiberAccessibilityAddTraits(_ traits: AccessibilityTraits) -> some View {
      if ProcessInfo.isTesting {
        self
      } else {
        self.accessibilityAddTraits(traits)
      }
    }

    @ViewBuilder
    public func fiberAccessibilityRemoveTraits(_ traits: AccessibilityTraits) -> some View {
      if ProcessInfo.isTesting {
        self
      } else {
        self.accessibilityRemoveTraits(traits)
      }
    }

    @ViewBuilder
    public func fiberAccessibilityFocus(_ binding: AccessibilityFocusState<Bool>.Binding)
      -> some View
    {
      if ProcessInfo.isTesting {
        self
      } else {
        self.accessibilityFocused(binding)
      }
    }

    @ViewBuilder
    public func fiberAccessibilityAction(
      _ actionKind: AccessibilityActionKind = .default, _ handler: @escaping () -> Void
    ) -> some View {
      if ProcessInfo.isTesting {
        self
      } else {
        self.accessibilityAction(actionKind, handler)
      }
    }

    @ViewBuilder
    public func fiberAccessibilityHidden(_ hidden: Bool) -> some View {
      if ProcessInfo.isTesting {
        self
      } else {
        self.accessibilityHidden(hidden)
      }
    }

    @ViewBuilder
    public func fiberAccessibilityAnnouncement(_ announcement: String, delayedBy: Double = 0.1)
      -> some View
    {
      if ProcessInfo.isTesting {
        self
      } else {
        self.onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + delayedBy) {
            guard UIAccessibility.isVoiceOverRunning else { return }
            UIAccessibility.post(notification: .announcement, argument: announcement)
          }
        }
      }
    }

    @ViewBuilder
    public func fiberAccessibilityAnnouncement<T: Publisher>(
      for publisher: T,
      debouncedBy: DispatchQueue.SchedulerTimeType.Stride = .seconds(1.5),
      announcement: @escaping (T.Output) -> String
    ) -> some View where T.Failure == Never {
      if ProcessInfo.isTesting {
        self
      } else {
        self.onReceive(publisher.debounce(for: debouncedBy, scheduler: DispatchQueue.main)) {
          value in
          UIAccessibility.post(notification: .announcement, argument: announcement(value))
        }
      }
    }
  }

  extension ProcessInfo {
    fileprivate static var isTesting: Bool {
      #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-testing")
      #else
        return false
      #endif
    }
  }

  extension UIAccessibility {
    public static func fiberPost(
      _ notification: UIAccessibility.Notification, argument: Any?, delayedBy: Double = 0.1
    ) {
      guard !ProcessInfo.isTesting else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + delayedBy) {
        UIAccessibility.post(notification: notification, argument: argument)
      }

    }
  }
#endif
