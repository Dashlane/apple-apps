import Foundation
import SwiftUI

public struct SelfHostedSSOView: View {
    
    let model: SelfHostedSSOViewModel
    let clearCookies: Bool
    
    public init(model: SelfHostedSSOViewModel, clearCookies: Bool = false) {
        self.model = model
        self.clearCookies = clearCookies
    }
    
    public var body: some View {
        SSOWebView(url: model.authorisationURL, clearCookies: clearCookies, didReceiveCallback: model.didReceiveCallback)
    }
}

struct SSOView_Previews: PreviewProvider {
    static var previews: some View {
        SelfHostedSSOView(model: SelfHostedSSOViewModel(login: "_",
                                    authorisationURL: URL(string: "_")!,
                                    completion: {_ in}))
    }
}
