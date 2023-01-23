import SwiftUI

public struct ChipsList: View {

    @ScaledMetric private var spacing = 12

    private let elements: [String]

                public init(_ elements: [String]) {
        self.elements = elements
    }

    public var body: some View {
        VWaterfallGrid(alignment: .leading, spacing: spacing) {
            ForEach(elements, id: \.self) { element in
                Chip(element)
            }
        }
    }
}

struct ChipsList_Previews: PreviewProvider {
    static var previews: some View {
        ChipsListPreview()
    }
}
