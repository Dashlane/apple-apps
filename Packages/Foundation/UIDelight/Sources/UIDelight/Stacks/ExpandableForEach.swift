import Foundation
import SwiftUI

public struct ExpandableForEach<Data, ID, Content, Label>: View where Data: RandomAccessCollection, ID: Hashable, Content: View, Label: View {

    let threshold: Int

            let data: Data

    let id: KeyPath<Data.Element, ID>

    @Binding
    var expanded: Bool

    @ViewBuilder
    var label: () -> Label

        var content: (Data.Element) -> Content

    public init(_ data: Data,
                id: KeyPath<Data.Element, ID>,
                threshold: Int = 5,
                expanded: Binding<Bool>,
                @ViewBuilder label: @escaping () -> Label,
                @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.threshold = threshold
        self._expanded = expanded
        self.label = label
        self.content = content
    }

    public var body: some View {
        list
        if data.count > threshold {
            Divider().padding(.horizontal, 12)
            Button(action: toggleExpansion, label: label).background(Color.clear)
        }

    }

    @ViewBuilder
    private var list: some View {
        ForEach(data.prefix(expanded ? .max : threshold), id: id, content: content)
    }

    func toggleExpansion() {
        expanded.toggle()
    }
}

struct ExpandableForEach_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            ExpandableForEach(
                ["1", "2", "3", "4", "5", "6"],
                id: \.self,
                expanded: .constant(true),
                label: {
                    Text("Show Less")
                },
                content: { element in
                    Text(element)
                }
            )
        }

    }
}
