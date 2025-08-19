import SwiftUI

extension Infobox {
  @ViewBuilder
  var background: some View {
    Group {
      switch container {
      case .list(.insetGrouped):
        Rectangle()
          .listRowInsets(.init())

      case .list(.plain), .root:
        RoundedRectangle(cornerRadius: containerCornerRadius, style: .continuous)
      }
    }
    .foregroundStyle(.ds.expressiveContainer)
  }

  var rowInsets: EdgeInsets? {
    switch container {
    case .list(.insetGrouped):
      EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    case .list(.plain), .root:
      nil
    }
  }
}

#Preview("Embed In Grouped List as Section") {
  List {
    Infobox("Title", description: "Description") {
      Button("Primary Button") {}
        .style(intensity: .quiet)
    }
    .style(mood: .danger)

  }.listStyle(.ds.insetGrouped)
}

#Preview("Embed In Grouped List with other elements") {
  List {
    Infobox("Title", description: "Description") {
      Button("Primary Button") {}
        .style(intensity: .quiet)
    }
    .style(mood: .danger)
    .listRowSeparator(.hidden)

    Text("Text")
    Text("Text")
  }.listStyle(.ds.insetGrouped)
}
