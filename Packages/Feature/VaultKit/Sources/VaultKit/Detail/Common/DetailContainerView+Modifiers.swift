import SwiftUI

struct DetailContainerViewSpecificDismissKey: EnvironmentKey {
  static var defaultValue: DetailContainerViewSpecificAction?
}

struct DetailContainerViewSpecificSaveKey: EnvironmentKey {
  static var defaultValue: DetailContainerViewSpecificAsyncAction?
}

public enum SpecificBackButton {
  case close
  case back
}

struct DetailContainerViewSpecificBackButtonKey: EnvironmentKey {
  static var defaultValue: SpecificBackButton?
}

extension EnvironmentValues {
  public var detailContainerViewSpecificDismiss: DetailContainerViewSpecificAction? {
    get { self[DetailContainerViewSpecificDismissKey.self] }
    set { self[DetailContainerViewSpecificDismissKey.self] = newValue }
  }

  public var detailContainerViewSpecificSave: DetailContainerViewSpecificAsyncAction? {
    get { self[DetailContainerViewSpecificSaveKey.self] }
    set { self[DetailContainerViewSpecificSaveKey.self] = newValue }
  }

  public var detailContainerViewSpecificBackButton: SpecificBackButton? {
    get { self[DetailContainerViewSpecificBackButtonKey.self] }
    set { self[DetailContainerViewSpecificBackButtonKey.self] = newValue }
  }
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
