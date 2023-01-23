import SwiftUI
import LoginKit

struct SplitViewPlaceholderView: View {

    var body: some View {
        LoginLogo().backgroundColorIgnoringSafeArea(Color(asset: FiberAsset.appBackground))
    }
}

struct SplitViewPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        SplitViewPlaceholderView()
    }
}
