import SwiftUI

extension DS {
  public enum ContainerContext {
    public enum ListStyle {
      case insetGrouped
      case plain
    }

    case root
    case list(ListStyle)
  }
}

extension EnvironmentValues {
  @Entry public var container: DS.ContainerContext = .root
}

extension View {
  public func containerContext(_ container: DS.ContainerContext?) -> some View {
    environment(\.container, container ?? .root)
  }
}
