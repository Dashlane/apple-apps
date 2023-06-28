import SwiftUI
import LoginKit

struct SplitViewPlaceholderView: View {

    var body: some View {
        LoginLogo()
            .backgroundColorIgnoringSafeArea(.ds.background.default)
    }
}

struct SplitViewPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        SplitViewPlaceholderView()
    }
}
