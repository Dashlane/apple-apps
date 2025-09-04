import Foundation
import SwiftTreats
import SwiftUI

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
    }.onChange(of: enabled) { _, enabled in
      if enabled {
        mainMenuBar.add(shortcut, action: action)
      } else {
        mainMenuBar.remove(shortcut)
      }
    }
  }
}

extension View {

  @ViewBuilder
  public func mainMenuShortcut(
    _ shortcut: DynamicShortcut,
    enabled: Bool = true,
    action: @escaping () -> Void
  ) -> some View {
    if !ProcessInfo.isTesting, Device.is(.pad, .mac, .vision) {
      self.modifier(
        MainMenuEnvironmentModifier(shortcut: shortcut, action: action, enabled: enabled))
    } else {
      self
    }
  }
}
