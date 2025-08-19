import CoreTypes
import SwiftUI

public struct AccessControlRequestViewModifier: ViewModifier {
  @StateObject var model: AccessControlRequestViewModifierModel

  public init(model: @autoclosure @escaping () -> AccessControlRequestViewModifierModel) {
    _model = .init(wrappedValue: model())
  }

  public func body(content: Content) -> some View {
    content
      .overFullScreen(item: $model.userVerificationRequest, mode: .topMost) { request in
        AccessControlView(model: model.makeAccessViewModel(request: request))
      }
      .environment(\.accessControl, model.accessControl)
  }
}

extension EnvironmentValues {
  @Entry
  public var accessControl: AccessControlHandler = .default
}
