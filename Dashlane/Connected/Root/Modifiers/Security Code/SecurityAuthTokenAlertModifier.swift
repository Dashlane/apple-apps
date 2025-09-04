import CoreLocalization
import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIDelight

@ViewInit
struct SecurityAuthTokenAlertModifier: ViewModifier {
  @StateObject var model: SecurityAuthTokenAlertModifierModel

  func body(content: Content) -> some View {
    content
      .fullScreenCover(item: $model.token) { token in
        SecurityAuthTokenAlert(token: token)
          .presentationBackground(.clear)
      }
  }
}
