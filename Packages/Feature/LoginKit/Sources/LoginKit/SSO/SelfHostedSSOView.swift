#if canImport(UIKit)
import Foundation
import SwiftUI
import CoreLocalization

public struct SelfHostedSSOView: View {

    let model: SelfHostedSSOViewModel
    let clearCookies: Bool

    public init(model: SelfHostedSSOViewModel, clearCookies: Bool = false) {
        self.model = model
        self.clearCookies = clearCookies
    }

    public var body: some View {
        SSOWebView(url: model.authorisationURL, clearCookies: clearCookies, didReceiveCallback: model.didReceiveCallback)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.Core.cancel) {
                        model.cancel()
                    }
                    .foregroundColor(.ds.text.brand.standard)
                }
            }
    }
}

struct SSOView_Previews: PreviewProvider {
    static var previews: some View {
        SelfHostedSSOView(model: SelfHostedSSOViewModel(login: "_",
                                    authorisationURL: URL(string: "_")!,
                                    completion: {_ in}))
    }
}

#endif
