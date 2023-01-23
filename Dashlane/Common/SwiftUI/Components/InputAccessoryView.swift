import Foundation
import SwiftUI

struct InputAccessoryView<V: View>: View {
    let view: V
    let backgroundColor: Color

    init(@ViewBuilder _ view: () -> V, backgroundColor: Color = Color(asset: FiberAsset.navigationBarBackground)) {
        self.view = view()
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        view
            .backgroundColorIgnoringSafeArea(backgroundColor)
    }
}
