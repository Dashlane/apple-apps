#if canImport(AuthenticationServices)
  import AuthenticationServices
#endif
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
#if canImport(DashlaneAPI)
  import DashlaneAPI
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

public protocol HomeAnnouncementsServicesInjecting {}

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
  public func makeAutofillOnboardingFlowViewModel(completion: @MainActor @escaping () -> Void)
    -> AutofillOnboardingFlowViewModel
  {
    return AutofillOnboardingFlowViewModel(
      autofillService: notificationKitAutofillService,
      capabilityService: capabilityService,
      featureService: notificationKitFeatureService,
      activityReporter: announcementsActivityReporter,
      userSettings: userSettings,
      autofillOnboardingIntroViewModelFactory: InjectedFactory(
        makeAutofillOnboardingIntroViewModel),
      completion: completion
    )
  }

}

extension HomeAnnouncementsServicesContainer {
  @MainActor
  public func makeAutofillOnboardingIntroViewModel(
    shouldShowSync: Bool, action: @MainActor @escaping () -> Void,
    dismiss: @MainActor @escaping () -> Void
  ) -> AutofillOnboardingIntroViewModel {
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
      premiumStatusProvider: premiumStatusProvider
    )
  }

}

extension HomeAnnouncementsServicesContainer {

  public func makeFreeTrialFlowViewModel(daysLeft: Int) -> FreeTrialFlowViewModel {
    return FreeTrialFlowViewModel(
      daysLeft: daysLeft,
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
  @MainActor
  public func makeHomeTopBannerViewModel(
    autofillBannerViewModel: AutofillBannerViewModel,
    authenticatorSunsetBannerViewModel: AuthenticatorSunsetBannerViewModel,
    isLastpassInstalled: Bool, credentialsCount: Int
  ) -> HomeTopBannerViewModel {
    return HomeTopBannerViewModel(
      autofillBannerViewModel: autofillBannerViewModel,
      authenticatorSunsetBannerViewModel: authenticatorSunsetBannerViewModel,
      deeplinkingService: deepLinkingService,
      userSettings: userSettings,
      featureService: notificationKitFeatureService,
      isLastpassInstalled: isLastpassInstalled,
      credentialsCount: credentialsCount,
      premiumFactory: InjectedFactory(makePremiumAnnouncementsViewModel)
    )
  }

}

extension HomeAnnouncementsServicesContainer {

  public func makePlanRecommandationAnnouncement() -> PlanRecommandationAnnouncement {
    return PlanRecommandationAnnouncement(
      userSettings: userSettings,
      syncedSettings: syncedSettings,
      premiumStatusProvider: premiumStatusProvider
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
  @MainActor
  public func makePremiumAnnouncementsViewModel(
    excludedAnnouncements: Set<PremiumAnnouncement> = []
  ) -> PremiumAnnouncementsViewModel {
    return PremiumAnnouncementsViewModel(
      premiumStatusProvider: premiumStatusProvider,
      productInfoUpdater: productInfoUpdater,
      featureService: notificationKitFeatureService,
      deeplinkService: deepLinkingService,
      sessionActivityReporter: announcementsActivityReporter,
      itemsLimitNotificationProvider: itemsLimitNotificationProvider,
      userDeviceAPI: userDeviceAPIClient,
      excludedAnnouncements: excludedAnnouncements
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

  public func makeUpdateOperatingSystemAnnouncement(
    informationProvider: DeviceInformationProvider = DeviceInformation(),
    cache: UpdateOperatingSystemCacheProtocol = UpdateOperatingSystemCache()
  ) -> UpdateOperatingSystemAnnouncement {
    return UpdateOperatingSystemAnnouncement(
      informationProvider: informationProvider,
      cache: cache
    )
  }

}

public typealias _AutofillActivationModalAnnouncementFactory = (
) -> AutofillActivationModalAnnouncement

extension InjectedFactory where T == _AutofillActivationModalAnnouncementFactory {

  public func make() -> AutofillActivationModalAnnouncement {
    return factory()
  }
}

extension AutofillActivationModalAnnouncement {
  public typealias Factory = InjectedFactory<_AutofillActivationModalAnnouncementFactory>
}

public typealias _AutofillOnboardingFlowViewModelFactory = @MainActor (
  _ completion: @MainActor @escaping () -> Void
) -> AutofillOnboardingFlowViewModel

extension InjectedFactory where T == _AutofillOnboardingFlowViewModelFactory {
  @MainActor
  public func make(completion: @MainActor @escaping () -> Void) -> AutofillOnboardingFlowViewModel {
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

extension InjectedFactory where T == _AutofillOnboardingIntroViewModelFactory {
  @MainActor
  public func make(
    shouldShowSync: Bool, action: @MainActor @escaping () -> Void,
    dismiss: @MainActor @escaping () -> Void
  ) -> AutofillOnboardingIntroViewModel {
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

public typealias _BrazeInAppModalAnnouncementFactory = (
) -> BrazeInAppModalAnnouncement

extension InjectedFactory where T == _BrazeInAppModalAnnouncementFactory {

  public func make() -> BrazeInAppModalAnnouncement {
    return factory()
  }
}

extension BrazeInAppModalAnnouncement {
  public typealias Factory = InjectedFactory<_BrazeInAppModalAnnouncementFactory>
}

public typealias _FreeTrialAnnouncementFactory = (
) -> FreeTrialAnnouncement

extension InjectedFactory where T == _FreeTrialAnnouncementFactory {

  public func make() -> FreeTrialAnnouncement {
    return factory()
  }
}

extension FreeTrialAnnouncement {
  public typealias Factory = InjectedFactory<_FreeTrialAnnouncementFactory>
}

public typealias _FreeTrialFlowViewModelFactory = (
  _ daysLeft: Int
) -> FreeTrialFlowViewModel

extension InjectedFactory where T == _FreeTrialFlowViewModelFactory {

  public func make(daysLeft: Int) -> FreeTrialFlowViewModel {
    return factory(
      daysLeft
    )
  }
}

extension FreeTrialFlowViewModel {
  public typealias Factory = InjectedFactory<_FreeTrialFlowViewModelFactory>
}

public typealias _HomeModalAnnouncementsSchedulerFactory = (
) -> HomeModalAnnouncementsScheduler

extension InjectedFactory where T == _HomeModalAnnouncementsSchedulerFactory {

  public func make() -> HomeModalAnnouncementsScheduler {
    return factory()
  }
}

extension HomeModalAnnouncementsScheduler {
  public typealias Factory = InjectedFactory<_HomeModalAnnouncementsSchedulerFactory>
}

public typealias _HomeModalAnnouncementsViewModelFactory = (
) -> HomeModalAnnouncementsViewModel

extension InjectedFactory where T == _HomeModalAnnouncementsViewModelFactory {

  public func make() -> HomeModalAnnouncementsViewModel {
    return factory()
  }
}

extension HomeModalAnnouncementsViewModel {
  public typealias Factory = InjectedFactory<_HomeModalAnnouncementsViewModelFactory>
}

public typealias _HomeTopBannerViewModelFactory = @MainActor (
  _ autofillBannerViewModel: AutofillBannerViewModel,
  _ authenticatorSunsetBannerViewModel: AuthenticatorSunsetBannerViewModel,
  _ isLastpassInstalled: Bool,
  _ credentialsCount: Int
) -> HomeTopBannerViewModel

extension InjectedFactory where T == _HomeTopBannerViewModelFactory {
  @MainActor
  public func make(
    autofillBannerViewModel: AutofillBannerViewModel,
    authenticatorSunsetBannerViewModel: AuthenticatorSunsetBannerViewModel,
    isLastpassInstalled: Bool, credentialsCount: Int
  ) -> HomeTopBannerViewModel {
    return factory(
      autofillBannerViewModel,
      authenticatorSunsetBannerViewModel,
      isLastpassInstalled,
      credentialsCount
    )
  }
}

extension HomeTopBannerViewModel {
  public typealias Factory = InjectedFactory<_HomeTopBannerViewModelFactory>
}

public typealias _PlanRecommandationAnnouncementFactory = (
) -> PlanRecommandationAnnouncement

extension InjectedFactory where T == _PlanRecommandationAnnouncementFactory {

  public func make() -> PlanRecommandationAnnouncement {
    return factory()
  }
}

extension PlanRecommandationAnnouncement {
  public typealias Factory = InjectedFactory<_PlanRecommandationAnnouncementFactory>
}

public typealias _PlanRecommandationViewModelFactory = (
) -> PlanRecommandationViewModel

extension InjectedFactory where T == _PlanRecommandationViewModelFactory {

  public func make() -> PlanRecommandationViewModel {
    return factory()
  }
}

extension PlanRecommandationViewModel {
  public typealias Factory = InjectedFactory<_PlanRecommandationViewModelFactory>
}

public typealias _PremiumAnnouncementsViewModelFactory = @MainActor (
  _ excludedAnnouncements: Set<PremiumAnnouncement>
) -> PremiumAnnouncementsViewModel

extension InjectedFactory where T == _PremiumAnnouncementsViewModelFactory {
  @MainActor
  public func make(excludedAnnouncements: Set<PremiumAnnouncement> = [])
    -> PremiumAnnouncementsViewModel
  {
    return factory(
      excludedAnnouncements
    )
  }
}

extension PremiumAnnouncementsViewModel {
  public typealias Factory = InjectedFactory<_PremiumAnnouncementsViewModelFactory>
}

public typealias _RateAppModalAnnouncementFactory = (
) -> RateAppModalAnnouncement

extension InjectedFactory where T == _RateAppModalAnnouncementFactory {

  public func make() -> RateAppModalAnnouncement {
    return factory()
  }
}

extension RateAppModalAnnouncement {
  public typealias Factory = InjectedFactory<_RateAppModalAnnouncementFactory>
}

public typealias _RateAppViewModelFactory = (
  _ sender: RateAppViewModel.Sender
) -> RateAppViewModel

extension InjectedFactory where T == _RateAppViewModelFactory {

  public func make(sender: RateAppViewModel.Sender) -> RateAppViewModel {
    return factory(
      sender
    )
  }
}

extension RateAppViewModel {
  public typealias Factory = InjectedFactory<_RateAppViewModelFactory>
}

public typealias _ResetMasterPasswordIntroViewModelFactory = (
) -> ResetMasterPasswordIntroViewModel

extension InjectedFactory where T == _ResetMasterPasswordIntroViewModelFactory {

  public func make() -> ResetMasterPasswordIntroViewModel {
    return factory()
  }
}

extension ResetMasterPasswordIntroViewModel {
  public typealias Factory = InjectedFactory<_ResetMasterPasswordIntroViewModelFactory>
}

public typealias _TrialFeaturesViewModelFactory = (
) -> TrialFeaturesViewModel

extension InjectedFactory where T == _TrialFeaturesViewModelFactory {

  public func make() -> TrialFeaturesViewModel {
    return factory()
  }
}

extension TrialFeaturesViewModel {
  public typealias Factory = InjectedFactory<_TrialFeaturesViewModelFactory>
}

public typealias _UpdateOperatingSystemAnnouncementFactory = (
  _ informationProvider: DeviceInformationProvider,
  _ cache: UpdateOperatingSystemCacheProtocol
) -> UpdateOperatingSystemAnnouncement

extension InjectedFactory where T == _UpdateOperatingSystemAnnouncementFactory {

  public func make(
    informationProvider: DeviceInformationProvider = DeviceInformation(),
    cache: UpdateOperatingSystemCacheProtocol = UpdateOperatingSystemCache()
  ) -> UpdateOperatingSystemAnnouncement {
    return factory(
      informationProvider,
      cache
    )
  }
}

extension UpdateOperatingSystemAnnouncement {
  public typealias Factory = InjectedFactory<_UpdateOperatingSystemAnnouncementFactory>
}
