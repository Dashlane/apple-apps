import LoginKit
import SwiftUI

struct SplitViewPlaceholderView: View {

  var body: some View {
    LoginLogo()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
  }
}

struct SplitViewPlaceholderView_Previews: PreviewProvider {
  static var previews: some View {
    SplitViewPlaceholderView()
  }
}
