import Foundation
import SwiftUI

public enum UserActivityType: String {
  case viewItem = "com.dashlane.view-item"
  case changePassword = "com.dashlane.change-password"
  case generatePassword = "com.dashlane.generate-password"
  case identityDashboard = "com.dashlane.identity-dashboard"
  case vpn = "com.dashlane.vpn"
}

extension NSUserActivity {
  public convenience init(activityType: UserActivityType) {
    self.init(activityType: activityType.rawValue)
  }

}

extension View {
  @ViewBuilder
  public func userActivity(
    _ activityType: UserActivityType,
    isActive: Bool = true,
    _ update: @escaping (NSUserActivity) -> Void
  ) -> some View {
    self.modifier(
      UserActivityViewModifier(
        activityType: activityType,
        isActive: isActive,
        update: update))
  }
}

public struct UserActivityViewModifier: ViewModifier {
  @State
  var activity: NSUserActivity
  let update: (NSUserActivity) -> Void
  let isActive: Bool

  public init(
    activityType: UserActivityType,
    isActive: Bool,
    update: @escaping (NSUserActivity) -> Void
  ) {
    self.isActive = isActive
    _activity = State(initialValue: NSUserActivity(activityType: activityType))
    self.update = update
  }

  public func body(content: Content) -> some View {
    content
      .onAppear {
        guard isActive else {
          return
        }
        update(activity)
        activity.becomeCurrent()
      }
      .onDisappear {
        activity.invalidate()
      }
      .onChange(of: isActive) { _, isActive in
        if isActive {
          update(activity)
          activity.becomeCurrent()
        } else {
          activity.resignCurrent()
        }
      }
  }
}
