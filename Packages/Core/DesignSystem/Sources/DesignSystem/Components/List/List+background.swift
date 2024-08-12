import Foundation
import SwiftUI

public enum ScrollContentBackgroundStyle {
  case `default`
  case alternate

  var backgroundColor: Color {
    switch self {
    case .default:
      return Color.ds.background.default
    case .alternate:
      return .ds.background.alternate
    }
  }
}

public enum ListAppearance {
  case insetGrouped
  case plain

  var backgroundStyle: ScrollContentBackgroundStyle {
    switch self {
    case .insetGrouped:
      return .alternate
    case .plain:
      return .default
    }
  }
}

extension View {
  public func scrollContentBackgroundStyle(_ style: ScrollContentBackgroundStyle) -> some View {
    self
      .background(style.backgroundColor)
      .scrollContentBackground(.hidden)
  }

  @ViewBuilder
  public func listAppearance(_ appearance: ListAppearance) -> some View {
    switch appearance {
    case .insetGrouped:
      self
        #if canImport(UIKit)
          .listStyle(.insetGrouped)
        #else
          .listStyle(.inset)
        #endif
        .scrollContentBackgroundStyle(appearance.backgroundStyle)
        .fieldAppearance(.grouped)
    case .plain:
      self
        .listStyle(.plain)
        .scrollContentBackgroundStyle(appearance.backgroundStyle)
    }
  }
}

struct ScrollContentBackgroundStyle_Previews: PreviewProvider {
  static var previews: some View {
    List {
      Section {
        Text("Hello World")
        DS.TextField("Firstname", text: .constant("Walter"))
      }
    }
    .listAppearance(.insetGrouped)
    .previewDisplayName("Default Background Style")

    List {
      Section {
        Text("Hello World")
        DS.TextField("Firstname", text: .constant("Walter"))
      }
    }
    .listAppearance(.plain)
    .previewDisplayName("Alternate Appearance")
  }
}
