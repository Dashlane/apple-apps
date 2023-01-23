import Foundation
import SwiftUI
import UIComponents

typealias SharedAsset = AuthenticatorAsset

struct AccountLoadingView: View {
    var body: some View {
        LottieView(.passwordChangerLoading)
            .frame(width: 64, height: 64, alignment: .center)
    }
}

struct AccountLoadingView_preview: PreviewProvider {
    static var previews: some View {
        AccountLoadingView()
    }
}
