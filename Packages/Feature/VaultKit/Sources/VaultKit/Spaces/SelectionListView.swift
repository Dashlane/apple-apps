import CorePremium
import DesignSystem
import Foundation
import SwiftUI

public struct SelectionListView<Value, Content>: View where Value: Identifiable, Content: View {

  @Binding
  var selection: Value

  let items: [Value]
  let content: (Value) -> Content
  let selectionDidChange: () -> Void

  @Environment(\.dismiss)
  private var dismiss

  public init(
    selection: Binding<Value>,
    items: [Value],
    selectionDidChange: @escaping () -> Void = {},
    @ViewBuilder content: @escaping (Value) -> Content
  ) {
    self._selection = selection
    self.items = items
    self.content = content
    self.selectionDidChange = selectionDidChange
  }

  public var body: some View {
    List(items) { item in
      Button(
        action: {
          self.selection = item
          self.dismiss()
          self.selectionDidChange()
        },
        label: {
          HStack(spacing: 0) {
            self.content(item)
              .frame(maxWidth: .infinity, alignment: .leading)
              .contentShape(Rectangle())

            if item.id == self.selection.id {
              Spacer()
              Image.ds.checkmark.outlined
                .foregroundStyle(Color.ds.text.brand.quiet)
            }
          }
        }
      )
      .fiberAccessibilityAddTraits(selection.id == item.id ? .isSelected : [])
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .toolbarBackground(Color.ds.container.agnostic.neutral.standard, for: .navigationBar)
  }
}

extension SelectionListView where Value == UserSpace, Content == AnyView {
  public init(
    selection: Binding<Value>,
    items: [Value],
    selectionDidChange: @escaping () -> Void = {}
  ) {
    self.init(
      selection: selection, items: items, selectionDidChange: selectionDidChange,
      content: { userSpace in
        HStack {
          UserSpaceIcon(space: userSpace, size: .normal)
          Text(userSpace.teamName)
        }.eraseToAnyView()
      })
  }
}
