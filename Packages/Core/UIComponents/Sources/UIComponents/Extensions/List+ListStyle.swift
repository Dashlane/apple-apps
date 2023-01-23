import SwiftUI

#if os(iOS)

public extension List {
        @ViewBuilder
    func detailListStyle() -> some View {
        self.listStyle(InsetGroupedListStyle())
    }
}

#endif
