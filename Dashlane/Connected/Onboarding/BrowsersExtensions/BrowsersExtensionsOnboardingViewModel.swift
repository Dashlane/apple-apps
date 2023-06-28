import Foundation
import Combine
import CoreSession
import DashlaneAppKit
import CoreFeature
import DashTypes

#if targetEnvironment(macCatalyst)
class BrowsersExtensionsOnboardingViewModel: ObservableObject {

    enum State: Equatable {
        case getOtherBrowser
        case enableSafari
        case browsersList
        case safariDisabled

        init(macBrowser: MacBrowser, isAutofillSafariDisabled: Bool = false) {
            if case .safari = macBrowser {
                self = isAutofillSafariDisabled ? .safariDisabled : .enableSafari
            } else {
                self = .getOtherBrowser
            }
        }
    }

    let defaultBrowser: MacBrowser
    let installedBrowsers: [MacBrowser]
    let isLegacyApplicationInstalled: Bool
    let isExtensionInstalled: (MacBrowser) -> Bool

    private let applicationOpener: ApplicationOpenerProtocol

    @Published
    var state: State

    let completion: () -> Void

    init(appKitBridge: AppKitBridgeProtocol,
         featureService: FeatureServiceProtocol,
         isExtensionInstalled: @escaping (MacBrowser) -> Bool,
         completion: @escaping () -> Void) {
        self.applicationOpener = appKitBridge.applicationOpener
        self.defaultBrowser = MacBrowser(name: appKitBridge.installedApplication.defaultBrowser())
        self.installedBrowsers = MacBrowser.allCases.filter({ appKitBridge.installedApplication.hasApplication(withBundleIdentifier: $0.rawValue) }).map({ $0 })
        self.isLegacyApplicationInstalled = appKitBridge.installedApplication.hasDashlaneLegacy()
        self.isExtensionInstalled = isExtensionInstalled
        self.completion = completion
        state = State(macBrowser: defaultBrowser, isAutofillSafariDisabled: featureService.isEnabled(.autofillSafariIsDisabled))
    }

    convenience init(appKitBridge: AppKitBridgeProtocol,
                     featureService: FeatureServiceProtocol,
                     sessionDirectory: SessionDirectory,
                     completion: @escaping () -> Void) {
        self.init(appKitBridge: appKitBridge,
                  featureService: featureService,
                  isExtensionInstalled: { $0.isBrowserExtensionInstalled(sessionDirectory: sessionDirectory) },
                  completion: completion)
    }

    private init(defaultBrowser: MacBrowser,
                 installedBrowsers: [MacBrowser],
                 isLegacyApplicationInstalled: Bool,
                 applicationOpener: ApplicationOpenerProtocol,
                 isExtensionInstalled: @escaping (MacBrowser) -> Bool,
                 completion: @escaping () -> Void = {}) {
        self.defaultBrowser = defaultBrowser
        self.installedBrowsers = installedBrowsers
        self.isLegacyApplicationInstalled = isLegacyApplicationInstalled
        self.applicationOpener = applicationOpener
        self.isExtensionInstalled = isExtensionInstalled
        self.completion = completion
        state = State(macBrowser: defaultBrowser)
    }

    func openSafari() {
        applicationOpener.openApplication(withBundleIdentifier: MacBrowser.safari.rawValue)
    }

    func useOtherBrowsers() {
        self.state = .browsersList
    }

    func skip() {
        completion()
    }

    func goToDefaultBrowserView() {
        state = State(macBrowser: defaultBrowser)
    }

    func getExtension(forBrowser browser: MacBrowser) {
        if case .safari = browser {
            state = .enableSafari
            return
        }

        let extensionURL = URL(string: "_")!
        applicationOpener.open(url: extensionURL,
                               inApplicationWithBundleIdentifier: browser.rawValue)
    }

    func openWebapp(in browser: MacBrowser) {
        guard browser != .safari else {
                                    openSafari()
            return
        }
        let appURL = URL(string: "_")!
        applicationOpener.open(url: appURL,
                               inApplicationWithBundleIdentifier: browser.rawValue)
    }

}

extension BrowsersExtensionsOnboardingViewModel {
    static func mock(browser: MacBrowser, installed: [MacBrowser], isLegacyInstalled: Bool) -> BrowsersExtensionsOnboardingViewModel {
        BrowsersExtensionsOnboardingViewModel(defaultBrowser: browser,
                                              installedBrowsers: installed,
                                              isLegacyApplicationInstalled: isLegacyInstalled,
                                              applicationOpener: ApplicationOpenerMock(),
                                              isExtensionInstalled: { _ in false })
    }
}
#endif
