#if canImport(BrazeKit)
import BrazeKit
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(CoreFeature)
import CoreFeature
#endif
#if canImport(CoreLocalization)
import CoreLocalization
#endif
#if canImport(CorePersonalData)
import CorePersonalData
#endif
#if canImport(CorePremium)
import CorePremium
#endif
#if canImport(CoreSession)
import CoreSession
#endif
#if canImport(CoreSettings)
import CoreSettings
#endif
#if canImport(CoreUserTracking)
import CoreUserTracking
#endif
#if canImport(DashTypes)
import DashTypes
#endif
#if canImport(DesignSystem)
import DesignSystem
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(SwiftTreats)
import SwiftTreats
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(UIComponents)
import UIComponents
#endif
#if canImport(UIDelight)
import UIDelight
#endif
#if canImport(UIKit)
import UIKit
#endif

public protocol HomeAnnouncementsServicesInjecting { }

 
extension HomeAnnouncementsServicesContainer {
        
        public func makeAutofillActivationModalAnnouncement() -> AutofillActivationModalAnnouncement {
            return AutofillActivationModalAnnouncement(
                            userSettings: userSettings,
                            autofillService: notificationKitAutofillService,
                            featureService: notificationKitFeatureService
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        @MainActor
        public func makeAutofillOnboardingFlowViewModel(completion: @MainActor @escaping () -> Void) -> AutofillOnboardingFlowViewModel {
            return AutofillOnboardingFlowViewModel(
                            autofillService: notificationKitAutofillService,
                            premiumService: announcementsPremiumService,
                            featureService: notificationKitFeatureService,
                            activityReporter: announcementsActivityReporter,
                            userSettings: userSettings,
                            autofillOnboardingIntroViewModelFactory: InjectedFactory(makeAutofillOnboardingIntroViewModel),
                            completion: completion
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        @MainActor
        public func makeAutofillOnboardingIntroViewModel(shouldShowSync: Bool, action: @MainActor @escaping () -> Void, dismiss: @MainActor @escaping () -> Void) -> AutofillOnboardingIntroViewModel {
            return AutofillOnboardingIntroViewModel(
                            shouldShowSync: shouldShowSync,
                            activityReporter: announcementsActivityReporter,
                            action: action,
                            dismiss: dismiss
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeBrazeInAppModalAnnouncement() -> BrazeInAppModalAnnouncement {
            return BrazeInAppModalAnnouncement(
                            brazeService: brazeServiceProtocol
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeFreeTrialAnnouncement() -> FreeTrialAnnouncement {
            return FreeTrialAnnouncement(
                            userSettings: userSettings,
                            syncedSettings: syncedSettings,
                            premiumService: announcementsPremiumService
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeFreeTrialFlowViewModel() -> FreeTrialFlowViewModel {
            return FreeTrialFlowViewModel(
                            trialFeaturesViewModelFactory: InjectedFactory(makeTrialFeaturesViewModel),
                            userSettings: userSettings
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeHomeModalAnnouncementsScheduler() -> HomeModalAnnouncementsScheduler {
            return HomeModalAnnouncementsScheduler(
                            brazeInAppModalAnnouncementFactory: InjectedFactory(makeBrazeInAppModalAnnouncement),
                            rateAppModalAnnouncement: InjectedFactory(makeRateAppModalAnnouncement),
                            freeTrialAnnouncement: InjectedFactory(makeFreeTrialAnnouncement),
                            planRecommandationAnnouncement: InjectedFactory(makePlanRecommandationAnnouncement),
                            autofillActivationAnnouncement: InjectedFactory(makeAutofillActivationModalAnnouncement),
                            updateOperatingSystemAnnouncement: InjectedFactory(makeUpdateOperatingSystemAnnouncement)
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeHomeModalAnnouncementsViewModel() -> HomeModalAnnouncementsViewModel {
            return HomeModalAnnouncementsViewModel(
                            homeModalAnnouncementsSchedulerFactory: InjectedFactory(makeHomeModalAnnouncementsScheduler),
                            freeTrialFlowViewModelFactory: InjectedFactory(makeFreeTrialFlowViewModel),
                            planRecommandationViewModelFactory: InjectedFactory(makePlanRecommandationViewModel),
                            rateAppViewModelFactory: InjectedFactory(makeRateAppViewModel),
                            autofillOnboardingFlowViewModelFactory: InjectedFactory(makeAutofillOnboardingFlowViewModel)
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makePlanRecommandationAnnouncement() -> PlanRecommandationAnnouncement {
            return PlanRecommandationAnnouncement(
                            userSettings: userSettings,
                            syncedSettings: syncedSettings,
                            premiumService: announcementsPremiumService
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makePlanRecommandationViewModel() -> PlanRecommandationViewModel {
            return PlanRecommandationViewModel(
                            deepLinkingService: deepLinkingService,
                            activityReporter: announcementsActivityReporter,
                            userSettings: userSettings
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeRateAppModalAnnouncement() -> RateAppModalAnnouncement {
            return RateAppModalAnnouncement(
                            session: session,
                            userSettings: userSettings
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeRateAppViewModel(sender: RateAppViewModel.Sender) -> RateAppViewModel {
            return RateAppViewModel(
                            login: login,
                            sender: sender,
                            userSettings: userSettings
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeResetMasterPasswordIntroViewModel() -> ResetMasterPasswordIntroViewModel {
            return ResetMasterPasswordIntroViewModel(
                            deepLinkingService: deepLinkingService
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeTrialFeaturesViewModel() -> TrialFeaturesViewModel {
            return TrialFeaturesViewModel(
                            capabilityService: capabilityService,
                            deepLinkingService: deepLinkingService,
                            activityReporter: announcementsActivityReporter
            )
        }
        
}

extension HomeAnnouncementsServicesContainer {
        
        public func makeUpdateOperatingSystemAnnouncement(informationProvider: DeviceInformationProvider = DeviceInformation(), cache: UpdateOperatingSystemCacheProtocol = UpdateOperatingSystemCache()) -> UpdateOperatingSystemAnnouncement {
            return UpdateOperatingSystemAnnouncement(
                            informationProvider: informationProvider,
                            cache: cache
            )
        }
        
}


public typealias _AutofillActivationModalAnnouncementFactory =  (
) -> AutofillActivationModalAnnouncement

public extension InjectedFactory where T == _AutofillActivationModalAnnouncementFactory {
    
    func make() -> AutofillActivationModalAnnouncement {
       return factory(
       )
    }
}

extension AutofillActivationModalAnnouncement {
        public typealias Factory = InjectedFactory<_AutofillActivationModalAnnouncementFactory>
}


public typealias _AutofillOnboardingFlowViewModelFactory = @MainActor (
    _ completion: @MainActor @escaping () -> Void
) -> AutofillOnboardingFlowViewModel

public extension InjectedFactory where T == _AutofillOnboardingFlowViewModelFactory {
    @MainActor
    func make(completion: @MainActor @escaping () -> Void) -> AutofillOnboardingFlowViewModel {
       return factory(
              completion
       )
    }
}

extension AutofillOnboardingFlowViewModel {
        public typealias Factory = InjectedFactory<_AutofillOnboardingFlowViewModelFactory>
}


public typealias _AutofillOnboardingIntroViewModelFactory = @MainActor (
    _ shouldShowSync: Bool,
    _ action: @MainActor @escaping () -> Void,
    _ dismiss: @MainActor @escaping () -> Void
) -> AutofillOnboardingIntroViewModel

public extension InjectedFactory where T == _AutofillOnboardingIntroViewModelFactory {
    @MainActor
    func make(shouldShowSync: Bool, action: @MainActor @escaping () -> Void, dismiss: @MainActor @escaping () -> Void) -> AutofillOnboardingIntroViewModel {
       return factory(
              shouldShowSync,
              action,
              dismiss
       )
    }
}

extension AutofillOnboardingIntroViewModel {
        public typealias Factory = InjectedFactory<_AutofillOnboardingIntroViewModelFactory>
}


public typealias _BrazeInAppModalAnnouncementFactory =  (
) -> BrazeInAppModalAnnouncement

public extension InjectedFactory where T == _BrazeInAppModalAnnouncementFactory {
    
    func make() -> BrazeInAppModalAnnouncement {
       return factory(
       )
    }
}

extension BrazeInAppModalAnnouncement {
        public typealias Factory = InjectedFactory<_BrazeInAppModalAnnouncementFactory>
}


public typealias _FreeTrialAnnouncementFactory =  (
) -> FreeTrialAnnouncement

public extension InjectedFactory where T == _FreeTrialAnnouncementFactory {
    
    func make() -> FreeTrialAnnouncement {
       return factory(
       )
    }
}

extension FreeTrialAnnouncement {
        public typealias Factory = InjectedFactory<_FreeTrialAnnouncementFactory>
}


public typealias _FreeTrialFlowViewModelFactory =  (
) -> FreeTrialFlowViewModel

public extension InjectedFactory where T == _FreeTrialFlowViewModelFactory {
    
    func make() -> FreeTrialFlowViewModel {
       return factory(
       )
    }
}

extension FreeTrialFlowViewModel {
        public typealias Factory = InjectedFactory<_FreeTrialFlowViewModelFactory>
}


public typealias _HomeModalAnnouncementsSchedulerFactory =  (
) -> HomeModalAnnouncementsScheduler

public extension InjectedFactory where T == _HomeModalAnnouncementsSchedulerFactory {
    
    func make() -> HomeModalAnnouncementsScheduler {
       return factory(
       )
    }
}

extension HomeModalAnnouncementsScheduler {
        public typealias Factory = InjectedFactory<_HomeModalAnnouncementsSchedulerFactory>
}


public typealias _HomeModalAnnouncementsViewModelFactory =  (
) -> HomeModalAnnouncementsViewModel

public extension InjectedFactory where T == _HomeModalAnnouncementsViewModelFactory {
    
    func make() -> HomeModalAnnouncementsViewModel {
       return factory(
       )
    }
}

extension HomeModalAnnouncementsViewModel {
        public typealias Factory = InjectedFactory<_HomeModalAnnouncementsViewModelFactory>
}


public typealias _PlanRecommandationAnnouncementFactory =  (
) -> PlanRecommandationAnnouncement

public extension InjectedFactory where T == _PlanRecommandationAnnouncementFactory {
    
    func make() -> PlanRecommandationAnnouncement {
       return factory(
       )
    }
}

extension PlanRecommandationAnnouncement {
        public typealias Factory = InjectedFactory<_PlanRecommandationAnnouncementFactory>
}


public typealias _PlanRecommandationViewModelFactory =  (
) -> PlanRecommandationViewModel

public extension InjectedFactory where T == _PlanRecommandationViewModelFactory {
    
    func make() -> PlanRecommandationViewModel {
       return factory(
       )
    }
}

extension PlanRecommandationViewModel {
        public typealias Factory = InjectedFactory<_PlanRecommandationViewModelFactory>
}


public typealias _RateAppModalAnnouncementFactory =  (
) -> RateAppModalAnnouncement

public extension InjectedFactory where T == _RateAppModalAnnouncementFactory {
    
    func make() -> RateAppModalAnnouncement {
       return factory(
       )
    }
}

extension RateAppModalAnnouncement {
        public typealias Factory = InjectedFactory<_RateAppModalAnnouncementFactory>
}


public typealias _RateAppViewModelFactory =  (
    _ sender: RateAppViewModel.Sender
) -> RateAppViewModel

public extension InjectedFactory where T == _RateAppViewModelFactory {
    
    func make(sender: RateAppViewModel.Sender) -> RateAppViewModel {
       return factory(
              sender
       )
    }
}

extension RateAppViewModel {
        public typealias Factory = InjectedFactory<_RateAppViewModelFactory>
}


public typealias _ResetMasterPasswordIntroViewModelFactory =  (
) -> ResetMasterPasswordIntroViewModel

public extension InjectedFactory where T == _ResetMasterPasswordIntroViewModelFactory {
    
    func make() -> ResetMasterPasswordIntroViewModel {
       return factory(
       )
    }
}

extension ResetMasterPasswordIntroViewModel {
        public typealias Factory = InjectedFactory<_ResetMasterPasswordIntroViewModelFactory>
}


public typealias _TrialFeaturesViewModelFactory =  (
) -> TrialFeaturesViewModel

public extension InjectedFactory where T == _TrialFeaturesViewModelFactory {
    
    func make() -> TrialFeaturesViewModel {
       return factory(
       )
    }
}

extension TrialFeaturesViewModel {
        public typealias Factory = InjectedFactory<_TrialFeaturesViewModelFactory>
}


public typealias _UpdateOperatingSystemAnnouncementFactory =  (
    _ informationProvider: DeviceInformationProvider,
    _ cache: UpdateOperatingSystemCacheProtocol
) -> UpdateOperatingSystemAnnouncement

public extension InjectedFactory where T == _UpdateOperatingSystemAnnouncementFactory {
    
    func make(informationProvider: DeviceInformationProvider = DeviceInformation(), cache: UpdateOperatingSystemCacheProtocol = UpdateOperatingSystemCache()) -> UpdateOperatingSystemAnnouncement {
       return factory(
              informationProvider,
              cache
       )
    }
}

extension UpdateOperatingSystemAnnouncement {
        public typealias Factory = InjectedFactory<_UpdateOperatingSystemAnnouncementFactory>
}

