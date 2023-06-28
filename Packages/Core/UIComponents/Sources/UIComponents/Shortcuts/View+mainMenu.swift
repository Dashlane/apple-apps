#if canImport(UIKit)
import Foundation
import SwiftUI
import SwiftTreats

struct MainMenuEnvironmentModifier: ViewModifier {
    let mainMenuBar = MainMenuBarBridge.shared
    let shortcut: DynamicShortcut
    let action: () -> Void
    let enabled: Bool

    func body(content: Content) -> some View {
        content.onAppear {
            if enabled {
                mainMenuBar.add(shortcut, action: action)
            }
        }.onDisappear {
            mainMenuBar.remove(shortcut)
        }.onChange(of: enabled) { enabled in
            if enabled {
                mainMenuBar.add(shortcut, action: action)
            } else {
                mainMenuBar.remove(shortcut)
            }
        }
    }
}

public extension View {

    @ViewBuilder
        func mainMenuShortcut(_ shortcut: DynamicShortcut,
                          enabled: Bool = true,
                          action: @escaping () -> Void) -> some View {
                if !ProcessInfo.isTesting, Device.isIpadOrMac {
            self.modifier(MainMenuEnvironmentModifier(shortcut: shortcut, action: action, enabled: enabled))
        } else {
            self
        }
    }
}
#endif
