import CoreSession
import SwiftUI

public enum SpecificBackButton {
  case close
  case back
}

extension EnvironmentValues {
  @Entry public var detailContainerViewSpecificDismiss: DetailContainerViewSpecificAction?
  @Entry public var detailContainerViewSpecificSave: DetailContainerViewSpecificAsyncAction?
  @Entry public var detailContainerViewSpecificBackButton: SpecificBackButton?
  @Entry public var authenticationMethod: AuthenticationMethod?
}

extension View {
  public func detailContainerViewSpecificDismiss(_ dismiss: DetailContainerViewSpecificAction?)
    -> some View
  {
    self.environment(\.detailContainerViewSpecificDismiss, dismiss)
  }

  public func detailContainerViewSpecificSave(_ save: DetailContainerViewSpecificAsyncAction)
    -> some View
  {
    self.environment(\.detailContainerViewSpecificSave, save)
  }

  public func detailContainerViewSpecificBackButton(_ type: SpecificBackButton) -> some View {
    self.environment(\.detailContainerViewSpecificBackButton, type)
  }
}

public struct DetailContainerViewSpecificAction {
  private let action: () -> Void

  public init(_ action: @escaping () -> Void) {
    self.action = action
  }

  public func callAsFunction() {
    action()
  }
}

public struct DetailContainerViewSpecificAsyncAction {
  private let action: () async -> Void

  public init(_ action: @escaping () async -> Void) {
    self.action = action
  }

  public func callAsFunction() async {
    await action()
  }
}
