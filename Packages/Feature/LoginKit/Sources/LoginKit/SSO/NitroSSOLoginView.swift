#if canImport(UIKit)
import Foundation
import SwiftUI
import CoreSession
import DashlaneAPI
import CoreLocalization

public struct NitroSSOLoginView: View {

    @StateObject
    var model: NitroSSOLoginViewModel
    let clearCookies: Bool

    public init(model: @autoclosure @escaping () -> NitroSSOLoginViewModel, clearCookies: Bool = false) {
        self._model = .init(wrappedValue: model())
        self.clearCookies = clearCookies
    }

    public var body: some View {
        ZStack {
            if let loginInfo = model.loginService {
                SSOWebView(url: loginInfo.authorisationURL,
                           injectionScript: loginInfo.injectionScript,
                           clearCookies: clearCookies,
                           didReceiveSAML: model.didReceiveSAML)
            } else {
                ProgressView()
            }
        }
        .animation(.default, value: model.loginService)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(CoreLocalization.L10n.Core.cancel) {
                    model.cancel()
                }
                .foregroundColor(.ds.text.brand.standard)
            }
        }
    }
}

struct NitroSSOLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NitroSSOLoginView(model: NitroSSOLoginViewModel(login: "_", nitroWebService: NitroAPIClient(engine: NitroAPIClientEngineMock(responses: [:])), completion: {_ in}))
    }
}
#endif
