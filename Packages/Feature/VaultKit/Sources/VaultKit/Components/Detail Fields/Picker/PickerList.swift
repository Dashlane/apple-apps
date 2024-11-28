import DesignSystem
import Foundation
import SwiftUI

struct DetailPickerList<Content: Equatable & Hashable & Identifiable, ContentView: View>: View {
  let title: String
  let items: [Content]
  let content: (Content?) -> ContentView
  let allowEmptySelection: Bool

  @Binding
  var selection: Content?

  @Environment(\.dismiss)
  private var dismiss

  init(
    title: String,
    items: [Content],
    selection: Binding<Content?>,
    allowEmptySelection: Bool,
    @ViewBuilder content: @escaping (Content?) -> ContentView
  ) {
    self.title = title
    self.items = items
    self._selection = selection
    self.allowEmptySelection = allowEmptySelection
    self.content = content
  }

  var body: some View {
    List {
      if allowEmptySelection {
        row(for: nil)
      }
      ForEach(items, id: \.self) { item in
        row(for: item)
      }
    }
    .navigationTitle(title)
    .toolbarBackground(.hidden, for: .navigationBar)
    .listAppearance(.insetGrouped)
  }

  func row(for item: Content?) -> some View {
    Button(
      action: {
        self.selection = item
        self.dismiss()
      },
      label: {
        HStack(spacing: 0) {
          content(item)
            .frame(maxWidth: .infinity, alignment: .leading)
          if item == self.selection {
            Spacer()
            Image(systemName: "checkmark")
              .foregroundColor(.ds.text.brand.quiet)
          }
        }
      }
    )
    .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
  }
}

struct DetailPickerList_Previews: PreviewProvider {
  static let items = [Item(title: "first"), Item(title: "second")]
  struct Item: Identifiable & Hashable {
    let id: String = UUID().uuidString
    let title: String
  }

  static var previews: some View {
    DetailPickerList(
      title: "The Title",
      items: items,
      selection: .constant(nil), allowEmptySelection: false
    ) { item in
      if let item = item {
        Text(item.title)
      } else {
        Text("none")
      }
    }
  }
}
