import AppTrackingTransparency
import CoreSession
import CoreTypes
import DashlaneAPI
import LoginKit
import UIKit
import UserTrackingFoundation

#if canImport(Adjust)
  import Adjust
#endif
#if canImport(AdSupport)
  import AdSupport
#endif

extension SessionServicesContainer {
  func apply(_ localConfiguration: LocalConfiguration) {
    if localConfiguration.isBiometricAuthenticationEnabled {
      try? lockService.secureLockConfigurator.enableBiometry()
    }

    if let pin = localConfiguration.pincode {
      try? lockService.secureLockConfigurator.enablePinCode(pin)
    }

    if case let .masterPassword(masterPassword, _) = session.authenticationMethod {
      if localConfiguration.isMasterPasswordResetEnabled {
        try? resetMasterPasswordService.activate(using: masterPassword)
      }

      if localConfiguration.isRememberMasterPasswordEnabled {
        try? lockService.secureLockConfigurator.enableRememberMasterPassword()
      }
    }
  }
}

extension ActivityReporterProtocol {
  func logAccountCreationSuccessful() {
    let idfv = UIDevice.current.identifierForVendor?.uuidString
    #if canImport(Adjust) && canImport(AdSupport)
      let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
      let isMarketingOptIn = ATTrackingManager.trackingAuthorizationStatus == .authorized

      report(
        UserEvent.CreateAccount(
          iosMarketing: .init(adid: Adjust.adid(), idfa: idfa, idfv: idfv),
          isMarketingOptIn: isMarketingOptIn,
          status: .success))
    #else
      report(
        UserEvent.CreateAccount(
          iosMarketing: .init(idfv: idfv),
          isMarketingOptIn: false,
          status: .success
        ))
    #endif
  }
}

extension AppServicesContainer {
  var accountCreationService: RegularAccountCreationService {
    RegularAccountCreationService(
      sessionsContainer: sessionContainer,
      sessionCleaner: sessionCleaner,
      accountCreationSettingsProvider: self,
      accountCreationSharingKeysProvider: self,
      appAPIClient: appAPIClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      logger: rootLogger[.session])
  }
}
