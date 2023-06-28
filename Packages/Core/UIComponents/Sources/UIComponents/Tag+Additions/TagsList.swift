#if canImport(UIKit)
import SwiftUI
import DesignSystem

public struct TagsList: View {

    @ScaledMetric private var spacing = 12

    private let elements: [String]

                public init(_ elements: [String]) {
        self.elements = elements
    }

    public var body: some View {
        VWaterfallGrid(alignment: .leading, spacing: spacing) {
            ForEach(elements, id: \.self) { element in
                Tag(element)
            }
        }
    }
}

struct TagsList_Previews: PreviewProvider {
    static var previews: some View {
        TagsListPreview()
    }
}
#endif
