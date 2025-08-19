import SwiftUI

extension View {
  @ViewBuilder
  public func listStyle(_ style: DS.ContainerContext.ListStyle) -> some View {
    switch style {
    case .insetGrouped:
      self
        .listStyle(InsetGroupedListStyle())
        .scrollContentBackgroundStyle(style.backgroundStyle)
        .containerContext(.list(.insetGrouped))
    case .plain:
      self
        .listStyle(PlainListStyle())
        .scrollContentBackgroundStyle(style.backgroundStyle)
        .containerContext(.list(.plain))
    }
  }
}

extension DS.ContainerContext.ListStyle {
  var backgroundStyle: ScrollContentBackgroundStyle {
    switch self {
    case .insetGrouped:
      return .alternate
    case .plain:
      return .default
    }
  }
}

extension DS.ContainerContext.ListStyle {
  public static var ds: DS.ContainerContext.ListStyle.Type {
    return DS.ContainerContext.ListStyle.self
  }
}

#Preview("plain") {
  List {
    Text("Text")
    DS.TextField("Firstname", text: .constant("Walter"))
  }.listStyle(.ds.plain)
}

#Preview("insetGrouped") {
  List {
    Section {
      Text("Text")
      DS.TextField("Firstname", text: .constant("Walter"))
    }
  }.listStyle(.ds.insetGrouped)
}
