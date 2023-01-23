import Foundation
import Combine
import CoreUserTracking
import DashlaneCrypto
import AuthenticatorKit
import SwiftTreats
import DashlaneAppKit

@MainActor
class StandaloneViewModel: ObservableObject {
    
    @Published
    var codes: Set<OTPInfo> = []
    
    @Published
    var lastCodeAdded: OTPInfo?
    
    @Published
    var displayedSheet: StandaloneViewSheet?
    
    @SharedUserDefault(key: AuthenticatorKey.showStandAloneOnboarding, userDefaults: ApplicationGroup.authenticatorUserDefaults)
    public var showStandAloneOnboarding: Bool?
    
    @Published
    var showOnboarding: Bool = false
    
    let state: PasswordAppState
    let unlock: () -> Void
    let services: StandAloneServicesContainer

    var requestRating: Bool {
        return services.appServices.ratingService.requestRating
    }

    var cancellables = Set<AnyCancellable>()

    init(services: StandAloneServicesContainer,
         state: PasswordAppState,
         unlock: @escaping () -> Void) {
        self.services = services
        self.state = state
        self.unlock = unlock
        showOnboarding = showStandAloneOnboarding ?? true

        services.databaseService.codesPublisher.sink(receiveValue: { codes in
                                                            if ProcessInfo.isTesting && !codes.isEmpty {
                self.finishOnboarding()
            }
            self.codes = codes
        }).store(in: &cancellables)
    }
    
    func makeAddItemRootViewModel(skipIntro: Bool) -> AddItemFlowViewModel {
        services.makeAddItemFlowViewModel(hasAtLeastOneTokenStoredInVault: !codes.isEmpty,
                                          mode: .standalone,
                                          skipIntro: skipIntro,
                                          completion: { self.lastCodeAdded = $0 })
    }
    
    func makeTokenListViewModel() -> TokenListViewModel {
        services.makeTokenListViewModel() { [weak self] otpInfo in
            self?.logDeletion(of: otpInfo)
        }
    }
    
    func makeDownloadDashlaneViewModel(showStorePage: @escaping (AppStoreProductViewer) -> Void) -> DownloadDashlaneViewModel {
        services.makeDownloadDashlaneViewModel(showAppStorePage: showStorePage)
    }
    
    func makeAddItemScanCodeFlowViewModel(otpInfo: OTPInfo, isFirstToken: Bool) -> AddItemScanCodeFlowViewModel {
        services.makeAddItemScanCodeFlowViewModel(otpInfo: otpInfo, mode: .standalone, isFirstToken: isFirstToken) { [weak self] (item, _) in
            self?.lastCodeAdded = item
            self?.displayedSheet = nil
        }
    }
    
    func logDeletion(of otpInfo: OTPInfo) {
        services.appServices.activityReporter.report(UserEvent.AuthenticatorRemoveOtpCode())
        services.appServices.activityReporter.report(AnonymousEvent.AuthenticatorRemoveOtpCode(authenticatorIssuerId: otpInfo.authenticatorIssuerId))
    }
    
    func didFinishRating() {
        services.appServices.ratingService.update()
    }
    
    func finishOnboarding() {
        showStandAloneOnboarding = false
        showOnboarding = false
    }
}

