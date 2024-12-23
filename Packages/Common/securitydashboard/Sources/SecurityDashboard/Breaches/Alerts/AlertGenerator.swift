import Foundation

public protocol PremiumInformation {
  var isPremium: Bool { get }
}

public struct AlertGenerator {

  public struct RequestInformation {
    public let format: AlertFormat
    public let premiumInformation: PremiumInformation

    public init(format: AlertFormat, premiumInformation: PremiumInformation) {
      self.format = format
      self.premiumInformation = premiumInformation
    }
  }

  public static func popup(
    for breach: Breach,
    compromising impactedCredentials: [SecurityDashboardCredential],
    leaking: Set<BreachesService.Password>,
    requestInformation: RequestInformation,
    localizationProvider: LocalizationProvider
  ) throws -> PopupAlertProtocol {

    let alertData = try AlertData(
      with: breach, compromising: impactedCredentials, leaking: leaking,
      requestInformation: requestInformation)

    return try AlertGenerator.popup(data: alertData, using: localizationProvider)
  }

  static func popup(data alertData: AlertData, using localizationProvider: LocalizationProvider)
    throws -> PopupAlertProtocol
  {
    switch alertData.alertType {
    case .dataLeakAlertWithCompromisedPasswordsAndPiis,
      .dataLeakAlertWithCompromisedPasswords,
      .dataLeakAlertWithCompromisedPiis,
      .dataLeakAlert,
      .publicAlertWithCompromisedPasswordsAndPiis,
      .publicAlertWithCompromisedPasswords,
      .publicAlertWithCompromisedPiis,
      .publicAlert:
      return try DashlaneSixPopupAlertBuilder(
        data: alertData, localizationProvider: localizationProvider
      ).build()
    case .dataLeakAlertHiddenContent:
      return try DataLeakHiddenPopupAlertBuilder(
        data: alertData, localizationProvider: localizationProvider
      ).build()
    case .dataLeakAlertDataContent:
      return try DataLeakContentPopupAlertBuilder(
        data: alertData, localizationProvider: localizationProvider
      ).build()
    case .dataLeakAlertWithLeakedData:
      return try DataLeakPlaintextPopupAlertBuilder(
        data: alertData, localizationProvider: localizationProvider
      ).build()
    }
  }

  public static func tray(
    for breach: Breach,
    compromising impactedCredentials: [SecurityDashboardCredential],
    leaking: Set<BreachesService.Password>,
    requestInformation: RequestInformation,
    localizationProvider: LocalizationProvider
  ) throws -> TrayAlertProtocol {

    let alertData = try AlertData(
      with: breach, compromising: impactedCredentials, leaking: leaking,
      requestInformation: requestInformation)

    return try AlertGenerator.tray(data: alertData, using: localizationProvider)
  }

  static func tray(data alertData: AlertData, using localizationProvider: LocalizationProvider)
    throws -> TrayAlertProtocol
  {
    switch alertData.alertType {
    case .dataLeakAlertWithCompromisedPasswordsAndPiis,
      .dataLeakAlertWithCompromisedPasswords,
      .dataLeakAlertWithCompromisedPiis,
      .dataLeakAlert,
      .publicAlertWithCompromisedPasswordsAndPiis,
      .publicAlertWithCompromisedPasswords,
      .publicAlertWithCompromisedPiis,
      .publicAlert:
      return try DashlaneSixTrayAlertBuilder(
        data: alertData, localizationProvider: localizationProvider
      ).build()
    case .dataLeakAlertHiddenContent:
      return try HiddenTrayAlertBuilder(data: alertData, localizationProvider: localizationProvider)
        .build()
    case .dataLeakAlertDataContent:
      return try DataLeakContentTrayAlertBuilder(
        data: alertData, localizationProvider: localizationProvider
      ).build()
    case .dataLeakAlertWithLeakedData:
      return try DataLeakPlaintextTrayAlertBuilder(
        data: alertData, localizationProvider: localizationProvider
      ).build()
    }
  }
}

extension AlertGenerator {

  public enum AlertError: Error {
    case alertTypeNotFound
    case breachDoesNotHaveALinkedDomain
    case breachDoesNotHaveANameOrLinkedDomain
    case breachDoesNotHaveACreationDate
    case breachDoesNotHaveAnEventDate
    case breachDoesNotHaveLeakedData
    case breachDoesNotHaveImpactedEmail
    case breachNotViewable
  }

  static func alertType(
    isDataLeak: Bool,
    hasCredentialsCompromised: Bool,
    hasPIIsCompromised: Bool,
    leakedPlaintextData: Bool,
    requestInformation: RequestInformation
  ) throws -> AlertType {

    switch (
      isDataLeak,
      hasCredentialsCompromised,
      hasPIIsCompromised,
      leakedPlaintextData,
      requestInformation.premiumInformation.isPremium,
      requestInformation.format
    ) {

    case (true, _, _, _, false, .hiddenInformation): return .dataLeakAlertHiddenContent
    case (true, _, _, false, true, _): return .dataLeakAlertDataContent

    case (true, _, _, true, true, _): return .dataLeakAlertWithLeakedData

    case (true, true, true, _, _, _): return .dataLeakAlertWithCompromisedPasswordsAndPiis
    case (true, true, false, _, _, _): return .dataLeakAlertWithCompromisedPasswords
    case (true, false, true, _, _, _): return .dataLeakAlertWithCompromisedPiis
    case (true, false, false, _, _, _): return .dataLeakAlert

    case (false, true, true, _, _, _): return .publicAlertWithCompromisedPasswordsAndPiis
    case (false, true, false, _, _, _): return .publicAlertWithCompromisedPasswords
    case (false, false, true, _, _, _): return .publicAlertWithCompromisedPiis
    case (false, false, false, _, _, _): return .publicAlert
    }
  }
}

extension AlertGenerator {

  public struct AlertData {

    public let breach: Breach
    public let impactedCredentials: [SecurityDashboardCredential]
    public let leakedPasswords: Set<BreachesService.Password>
    public let alertType: AlertType

    var numberOfCompromisedCredentials: Int {
      return impactedCredentials.count
    }

    init(
      with breach: Breach,
      compromising impactedCredentials: [SecurityDashboardCredential],
      leaking: Set<BreachesService.Password>,
      requestInformation: RequestInformation
    ) throws {

      self.breach = breach
      self.impactedCredentials = impactedCredentials
      self.leakedPasswords = leaking
      let hasCredentialsCompromised: Bool = {
        let leakedData = breach.leakedData()
        guard !breach.isDataLeak else {
          return !impactedCredentials.isEmpty || leakedData.contains(.password)
        }
        return !impactedCredentials.isEmpty && leakedData.contains(.password)
      }()

      let leakedPlaintextData = breach.domains().isEmpty

      self.alertType = try AlertGenerator.alertType(
        isDataLeak: breach.isDataLeak,
        hasCredentialsCompromised: hasCredentialsCompromised,
        hasPIIsCompromised: breach.containsPII,
        leakedPlaintextData: leakedPlaintextData,
        requestInformation: requestInformation)

      guard self.alertType.viewable else {
        throw AlertError.breachNotViewable
      }
    }

    public init(
      breach: Breach, impactedCredentials: [SecurityDashboardCredential] = [],
      leaking: Set<BreachesService.Password> = [], alertType: AlertType
    ) {
      self.breach = breach
      self.impactedCredentials = impactedCredentials
      self.alertType = alertType
      self.leakedPasswords = leaking
    }

  }
}

extension Breach {

  public var isDataLeak: Bool {
    return self.kind == .dataLeak
  }

  public var containsPII: Bool {
    let leaked = leakedData()
    if self.kind == .dataLeak && leaked == [.email] {
      return true
    } else if self.kind == .dataLeak {
      return leaked.containsPII(except: [.email])
    } else {
      return leaked.containsPII()
    }
  }

  public var leaksPassword: Bool {
    return (self.leakedData()).contains(.password)
  }
}

extension Array where Element == LeakedData {
  fileprivate func containsPII(except: [LeakedData] = []) -> Bool {
    return self.first(where: { $0 != .password && !except.contains($0) }) != nil
  }
}
