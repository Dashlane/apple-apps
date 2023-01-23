import Foundation
import DashTypes
import CorePersonalData
import Combine
import CoreSpotlight
import LoginKit
import NotificationKit
import UIKit

protocol DeepLinkingServiceProtocol {
    var deepLinkPublisher: AnyPublisher<DeepLink, Never> { get }

    func handleLink(_ link: DeepLink)
    func handleURL(_ url: URL)

    func resetLastLink()
}

class DeepLinkingService: DeepLinkingServiceProtocol {
    private static let scheme = "dashlane:///"

    var subscriptions = Set<AnyCancellable>()
    weak var sessionLifeCycleHandler: SessionLifeCycleHandler?
    let notificationService: NotificationService

    @Published
    private var lastLink: DeepLink?

    var deepLinkPublisher: AnyPublisher<DeepLink, Never> {
        return $lastLink.compactMap { $0 }.eraseToAnyPublisher()
    }

    let brazeService: BrazeServiceProtocol

    init(sessionLifeCycleHandler: SessionLifeCycleHandler,
         notificationService: NotificationService,
         brazeService: BrazeServiceProtocol) {
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.notificationService = notificationService
        self.brazeService = brazeService
        configureDeeplinksFromNotifications()
    }

    func unload() {
        resetLastLink()
    }

    func resetLastLink() {
        lastLink = nil
    }

    func handleLink(_ link: DeepLink) {
        self.lastLink = link
    }

    func handleURL(_ url: URL) {
        guard let deeplink = DeepLink(url: url) else {
            return
        }

        self.handleLink(deeplink)
    }

    func handle(_ userActivity: NSUserActivity) {
                if userActivity.isFromUniversalLink, let url = userActivity.webpageURL {
                        handleURL(url)
        }

                else if UserActivityType(rawValue: userActivity.activityType) != nil,
                let rawDeeplink = userActivity[.deeplink] as? String,
                let deeplink = DeepLink(userActivityDeepLink: rawDeeplink) {
            handleLink(deeplink)
        }

                else if userActivity.isSearchContinuation, let query = userActivity.userInfo?[CSSearchQueryString] as? String {
            self.handleLink(.search(query))
        } else if userActivity.isSpotlightResult {
            guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                  let deepLink = DeepLink(userActivityDeepLink: identifier) else {
                return
            }
            handleLink(deepLink)
        }

                else if userActivity.isPasswordGenerationIntent, let password = UIPasteboard.general.string {
            var generatedPassword = GeneratedPassword()
            generatedPassword.password = password
            generatedPassword.generatedDate = Date()
            generatedPassword.platform = System.platform

            let deeplink = DeepLink.prefilledCredential(password: generatedPassword)
            self.handleLink(deeplink)
        }
    }
}

extension DeepLinkingService {
    private class FakeDeepLinkingService: DeepLinkingServiceProtocol {
        var deepLinkPublisher: AnyPublisher<DeepLink, Never> { Empty().eraseToAnyPublisher() }
        func handleLink(_ link: DeepLink) {}
        func handleURL(_ url: URL) {}
        func resetLastLink() {}
    }

    static var fakeService: DeepLinkingServiceProtocol {
        return FakeDeepLinkingService()
    }
}

extension DeepLinkingServiceProtocol {
    func settingsComponentPublisher() -> AnyPublisher<SettingsDeepLinkComponent, Never> {
        deepLinkPublisher
            .removeDuplicates(by: { $0.urlRepresentation == $1.urlRepresentation })
            .compactMap({ deepLink -> SettingsDeepLinkComponent? in
                guard case let .settings(component) = deepLink else {
                    return nil
                }
                return component
            }).eraseToAnyPublisher()
    }
}
