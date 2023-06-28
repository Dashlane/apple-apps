import SwiftUI
import UIDelight
import DesignSystem

#if !os(macOS)
public struct SuggestionsDetailView: View {
    let items: [String]

    @Binding
    var selection: String

    @Environment(\.dismiss)
    private var dismiss

    public init(items: [String], selection: Binding<String>) {
        self.items = items
        _selection = selection
    }

    public var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                HStack(spacing: 0) {
                    Text(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapWithFeedback {
                            self.selection = item
                            self.dismiss()
                    }
                    if item == self.selection {
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.ds.border.neutral.quiet.idle)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SuggestionsDetailView_Previews: PreviewProvider {
    static let items = ["first", "second"]
    struct Item: Identifiable, Hashable {
        let id: String = UUID().uuidString
        let title: String
    }

    static var previews: some View {
        SuggestionsDetailView(items: items, selection: .constant("first"))
    }
}
#endif
