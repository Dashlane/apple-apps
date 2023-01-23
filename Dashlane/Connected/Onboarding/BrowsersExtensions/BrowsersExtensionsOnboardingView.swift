import SwiftUI
import UIDelight

#if targetEnvironment(macCatalyst)
struct BrowsersExtensionsOnboardingView: View {

    @ObservedObject
    var viewModel: BrowsersExtensionsOnboardingViewModel
    var body: some View {
        ZStack {
            Color(asset: FiberAsset.searchBarBackgroundInactive).ignoresSafeArea()

            GeometryReader { reader in
                ScrollView {
                    HStack {
                        Group {
                            switch viewModel.state {
                            case .enableSafari:
                                EnableSafariOnboardingView(isLegacyApplicationInstalled: viewModel.isLegacyApplicationInstalled,
                                                           openSafari: viewModel.openSafari,
                                                           otherBrowsers: viewModel.useOtherBrowsers,
                                                           skip: viewModel.skip)
                            case .safariDisabled:
                                SafariDisabledOnboardingView(completion: viewModel.completion)
                            case .getOtherBrowser:
                                EnableOtherBrowserOnboardingView(browser: viewModel.defaultBrowser,
                                                                 isExtensionInstalled: viewModel.isExtensionInstalled(viewModel.defaultBrowser),
                                                                 getExtension: { viewModel.getExtension(forBrowser: viewModel.defaultBrowser) },
                                                                 openExtension: { viewModel.openWebapp(in: viewModel.defaultBrowser) },
                                                                 otherBrowsers: viewModel.useOtherBrowsers,
                                                                 skip: viewModel.skip)
                            case .browsersList:
                                BrowsersExtensionsListView(availableBrowsers: viewModel.installedBrowsers,
                                                           back: viewModel.goToDefaultBrowserView,
                                                           skip: viewModel.skip,
                                                           getExtension: viewModel.getExtension(forBrowser:),
                                                           isExtensionInstalled: viewModel.isExtensionInstalled,
                                                           openExtension: viewModel.openWebapp(in:))
                                    .transition(.move(edge: .trailing))
                            }
                        }
                    }
                    .animation(.default, value: viewModel.state)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity, minHeight: reader.size.height)
                }
            }.frame(maxHeight: .infinity)
        }
    }

}

struct BrowsersExtensionsOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(deviceRange: .some([.iPadPro])) {
            BrowsersExtensionsOnboardingView(viewModel: BrowsersExtensionsOnboardingViewModel.mock(browser: .chrome, installed: [.chrome, .safari, .firefox, .edge], isLegacyInstalled: false))
        }
    }
}
#endif
