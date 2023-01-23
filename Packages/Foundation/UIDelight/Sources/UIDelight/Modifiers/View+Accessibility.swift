import Foundation
import SwiftUI
import Combine
#if os(iOS)
import UIKit
#endif

public extension View {

                @ViewBuilder
    func fiberAccessibilityLabel(_ label: Text) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.accessibilityLabel(label)
        }
    }

                @ViewBuilder
    func fiberAccessibilityHint(_ hint: Text) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.accessibilityHint(hint)
        }
    }

        @ViewBuilder
    func fiberAccessibilityElement(children: AccessibilityChildBehavior = .ignore) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.accessibilityElement(children: children)
        }
    }

        @ViewBuilder
    func fiberAccessibilityAddTraits(_ traits: AccessibilityTraits) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.accessibilityAddTraits(traits)
        }
    }

        @ViewBuilder
    func fiberAccessibilityRemoveTraits(_ traits: AccessibilityTraits) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.accessibilityRemoveTraits(traits)
        }
    }

        @ViewBuilder
    func fiberAccessibilityFocus(_ binding: AccessibilityFocusState<Bool>.Binding) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.accessibilityFocused(binding)
        }
    }

        @ViewBuilder
    func fiberAccessibilityAction(_ actionKind: AccessibilityActionKind = .default, _ handler: @escaping () -> Void) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.accessibilityAction(actionKind, handler)
        }
    }

        @ViewBuilder
    func fiberAccessibilityHidden(_ hidden: Bool) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.accessibilityHidden(hidden)
        }
    }

                            @ViewBuilder
    func fiberAccessibilityAnnouncement(_ announcement: String, delayedBy: Double = 0.1) -> some View {
        if ProcessInfo.isTesting {
            self
        } else {
            self.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delayedBy) {
#if os(iOS)
                    guard UIAccessibility.isVoiceOverRunning else { return }
                    UIAccessibility.post(notification: .announcement, argument: announcement)
#else
                    guard NSWorkspace.shared.isVoiceOverEnabled else { return }
                    NSAccessibility.post(
                        element: NSApp.mainWindow as Any,
                        notification: .announcementRequested,
                        userInfo: [
                            .announcement: announcement,
                            .priority: NSAccessibilityPriorityLevel.high.rawValue
                        ]
                    )
#endif
                }
            }
        }
    }

                                    @ViewBuilder
    func fiberAccessibilityAnnouncement<T: Publisher>(for publisher: T,
                                                      debouncedBy: DispatchQueue.SchedulerTimeType.Stride = .seconds(1.5),
                                                      announcement: @escaping (T.Output) -> String
    ) -> some View where T.Failure == Never {
        if ProcessInfo.isTesting {
            self
        } else {
            #if os(iOS)
            self.onReceive(publisher.debounce(for: debouncedBy, scheduler: DispatchQueue.main)) { value in
                UIAccessibility.post(notification: .announcement, argument: announcement(value))
            }
            #else
            self
            #endif
        }
    }
}

private extension ProcessInfo {
    static var isTesting: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-testing")
        #else
        return false
        #endif
    }
}

#if canImport(UIKit)
public extension UIAccessibility {
    static func fiberPost(_ notification: UIAccessibility.Notification, argument: Any?) {
        guard !ProcessInfo.isTesting else { return }
        UIAccessibility.post(notification: notification, argument: argument)
    }
}
#elseif canImport(AppKit)
public extension NSAccessibility {
    static func fiberPost(notification announcement: String,
                          priority: NSAccessibilityPriorityLevel = .medium) {
        guard !ProcessInfo.isTesting, let mainWindow = NSApp.mainWindow else { return }
        NSAccessibility.post(
            element: mainWindow,
            notification: .announcementRequested,
            userInfo: [
                .announcement: announcement,
                .priority: NSAccessibilityPriorityLevel.high.rawValue
            ]
        )    }
}
#endif
