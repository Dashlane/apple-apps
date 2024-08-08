import Foundation

struct AlertBuildersUtils {}

extension AlertBuildersUtils {

  struct AlertTitle {
    let dataLeakTitleKey: LocalizationKey
    let regularAlertTitleKey: LocalizationKey
    let dataContentTitleKey: LocalizationKey
  }

  static func generateTitle(
    for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider,
    details: AlertTitle
  ) throws -> String {

    let localizationKey: LocalizationKey = {
      switch alertData.alertType {
      case .dataLeakAlertWithCompromisedPasswordsAndPiis,
        .dataLeakAlertWithCompromisedPasswords,
        .dataLeakAlertWithCompromisedPiis,
        .dataLeakAlert:
        return details.dataLeakTitleKey
      case .publicAlertWithCompromisedPasswordsAndPiis,
        .publicAlertWithCompromisedPasswords,
        .publicAlertWithCompromisedPiis,
        .publicAlert:
        return details.regularAlertTitleKey
      case .dataLeakAlertHiddenContent,
        .dataLeakAlertDataContent,
        .dataLeakAlertWithLeakedData:
        return details.dataContentTitleKey
      }
    }()

    return try alertData.breach.title(using: localizationKey, and: localizationProvider)
  }
}

extension Breach {
  fileprivate func title(using key: LocalizationKey, and localizationProvider: LocalizationProvider)
    throws -> String
  {
    guard let name = self.name ?? self.domains().first else {
      throw AlertGenerator.AlertError.breachDoesNotHaveANameOrLinkedDomain
    }
    let text = String(format: localizationProvider.localizedString(for: key), name)
    return text
  }
}

extension AlertBuildersUtils {

  struct UserDataDetails {
    let emailsKey: LocalizationKey
    let domainsKey: LocalizationKey
    let usernamesKey: LocalizationKey
  }

  static func generateUserDataDetails(
    for alertData: AlertGenerator.AlertData,
    and localizationProvider: LocalizationProvider,
    using details: UserDataDetails,
    and dataInvolvedDetails: DataInvolvedDetails? = nil
  ) throws -> AlertSection? {

    let maximumNumberOfElements = 5

    func generateSection(for data: Set<String>, using key: LocalizationKey) -> AlertSection? {
      guard data.count > 0 else { return nil }
      return AlertSection(
        title: AlertSection.Title(localizationProvider.localizedString(for: key)),
        contents: [data.joined(separator: ", ")])
    }

    let emails = Set(
      (alertData.impactedCredentials.compactMap({ $0.email }) + (alertData.breach.impactedEmails))
        .filter({ !$0.isEmpty })
        .prefix(maximumNumberOfElements))
    let domains = Set(
      (alertData.impactedCredentials.compactMap({ $0.domain }) + alertData.breach.domains())
        .filter({ !$0.isEmpty })
        .prefix(maximumNumberOfElements))

    let dataInvolved: AlertSection? = try {
      guard let dataInvolvedDetails = dataInvolvedDetails else { return nil }
      guard
        let dataInvolvedSection = try generateDataInvolvedDetails(
          for: alertData, and: localizationProvider, details: dataInvolvedDetails)
      else {
        return nil
      }
      let alertSection = AlertSection(
        title: dataInvolvedSection.title,
        contents: [dataInvolvedSection.contents.joined(separator: ", ")])
      return alertSection
    }()

    let usernames: Set<String> = {
      guard alertData.breach.leakedData().contains(.username) else { return [] }
      return Set(
        alertData.impactedCredentials.compactMap({ $0.username })
          .filter({ !$0.isEmpty })
          .prefix(maximumNumberOfElements))
    }()

    let sections = [
      generateSection(for: emails, using: details.emailsKey),
      generateSection(for: domains, using: details.domainsKey),
      dataInvolved,
      generateSection(for: usernames, using: details.usernamesKey),
    ]
    let finalSection =
      sections
      .compactMap({ $0 })
      .reduce(into: AlertSection(title: AlertSection.Title(""), contents: [])) {
        (result, section) in
        if !result.title.data.isEmpty {
          result.title.data.append("\n\n")
        }
        result.title.data.append(section.title.data)
        result.contents += section.contents
      }
    return finalSection
  }
}

extension AlertBuildersUtils {

  struct DataInvolvedDetails {
    let titleKey: LocalizationKey
  }

  static func generateDataInvolvedDetails(
    for alertData: AlertGenerator.AlertData,
    and localizationProvider: LocalizationProvider,
    details: DataInvolvedDetails
  ) throws -> AlertSection? {
    let leakedData = alertData.breach.leakedData()
    guard !leakedData.isEmpty else {
      throw AlertGenerator.AlertError.breachDoesNotHaveLeakedData
    }

    let leakedDataStrings =
      leakedData
      .filter { $0 != .unknown }
      .compactMap { LocalizationKey.key(for: $0) }
      .compactMap { localizationProvider.localizedString(for: $0) }
    return AlertSection(
      title: AlertSection.Title(localizationProvider.localizedString(for: details.titleKey)),
      contents: leakedDataStrings)
  }
}

extension AlertBuildersUtils {

  struct CompromisedAccountsRecommendation {
    let onlyPIIsCompromisedKey: LocalizationKey
    let noPasswordCompromisedKey: LocalizationKey
    let oneCompromisedKey: LocalizationKey
    let multipleCompromisedKey: LocalizationKey
  }

  static func generateCompromisedAccountsRecommendation(
    for alertData: AlertGenerator.AlertData,
    and localizationProvider: LocalizationProvider,
    details: CompromisedAccountsRecommendation
  ) throws -> AlertSection? {

    switch alertData.numberOfCompromisedCredentials {
    case 0:
      guard alertData.alertType.isDataLeakAlert else { return nil }

      switch alertData.alertType {
      case .dataLeakAlertWithCompromisedPiis:
        return AlertSection(
          title: AlertSection.Title(
            localizationProvider.localizedString(for: details.onlyPIIsCompromisedKey)),
          contents: [])
      case .dataLeakAlertWithCompromisedPasswords, .dataLeakAlertWithCompromisedPasswordsAndPiis:
        return AlertSection(
          title: AlertSection.Title(
            localizationProvider.localizedString(for: details.noPasswordCompromisedKey)),
          contents: alertData.breach.domains())
      default:
        return nil
      }
    case 1:
      return AlertSection(
        title: AlertSection.Title(
          localizationProvider.localizedString(for: details.oneCompromisedKey)),
        contents: ["\(alertData.numberOfCompromisedCredentials)"])
    default:
      return AlertSection(
        title: AlertSection.Title(
          localizationProvider.localizedString(for: details.multipleCompromisedKey)),
        contents: ["\(alertData.numberOfCompromisedCredentials)"])
    }
  }
}
