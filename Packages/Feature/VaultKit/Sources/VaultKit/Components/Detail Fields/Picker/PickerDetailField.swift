#if os(iOS)
import DesignSystem
import SwiftUI
import CorePersonalData
import UIDelight
import SwiftTreats
import UIComponents

public struct PickerDetailField<Value, Content>: DetailField where Value: Hashable & Identifiable, Content: View {

    let title: String

    @Binding
    var selection: Value?

    let elements: [Value]
    let content: (Value?) -> Content

    @Environment(\.detailMode)
    var detailMode

    let allowEmptySelection: Bool

    @State
    private var showPicker: Bool = false

    public init(
        title: String,
        selection: Binding<Value?>,
        elements: [Value],
        allowEmptySelection: Bool = false,
        @ViewBuilder content: @escaping (Value?) -> Content
    ) {
        self.title = title
        self._selection = selection
        self.elements = elements
        self.content = content
        self.allowEmptySelection = allowEmptySelection
    }

    @ViewBuilder
    public var body: some View {
        mainContent(
            Button(action: {
                                #if !EXTENSION
                UIApplication.shared.endEditing()
                #endif
                showPicker = true
            }, label: {
                HStack(spacing: 0) {
                    self.content(selection)
                        .foregroundColor(.ds.text.neutral.standard)
                        .labeled(title)
                    if detailMode.isEditing {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.ds.text.neutral.quiet)
                    }
                }

            })
            .disabled(!detailMode.isEditing)
        )
    }

    @ViewBuilder
    func mainContent(_ button: some View) -> some View {
        if !detailMode.isEditing {
            button
        } else {
            button
                .navigation(isActive: $showPicker) {
                    DetailPickerList(
                        title: title,
                        items: elements,
                        selection: $selection,
                        allowEmptySelection: allowEmptySelection,
                        content: content
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
        }
    }
}

public extension PickerDetailField where Value: Defaultable {
    init(title: String,
         selection: Binding<Value>,
         elements: [Value],
         @ViewBuilder content: @escaping (Value) -> Content) {

        self.init(title: title,
                  selection: .init(get: {
            return selection.wrappedValue
        }, set: { newValue in
            selection.wrappedValue = newValue ?? .defaultValue
        }), elements: elements,
                  allowEmptySelection: false) { value in
            let value = value ?? .defaultValue
            return content(value)
        }
    }
}

struct PickerDetailField_Previews: PreviewProvider {
    struct Element: Identifiable, Hashable {
        let name: String
        var id: String {
            return name
        }
    }

    static var previews: some View {
        Form {
            PickerDetailField(title: "title",
                              selection: .constant(nil),
                              elements: [Element(name: "first"), Element(name: "second")],
                              content: { item in
                Text(item != nil ? item!.name : "None")
            })
            PickerDetailField(title: "title",
                              selection: .constant(nil),
                              elements: [Element(name: "first"), Element(name: "second")],
                              content: { item in
                Text(item != nil ? item!.name : "None")
                              }).environment(\.detailMode, .updating)
        }
    }
}
#endif
