import Foundation

public struct DashlaneSixTrayAlert: TrayAlertProtocol {

    public let title: String
    public let description: AlertSection?
    public let details: AlertSection?
    public let recommendation: AlertSection?

    public let buttons: Buttons

    public let timestamp: String?
    public let date: AlertSection?

    public let data: AlertGenerator.AlertData
}

struct DashlaneSixTrayAlertBuilder: TrayAlertBuilderProtocol {

    let data: AlertGenerator.AlertData
    let localizationProvider: LocalizationProvider

    init(data: AlertGenerator.AlertData, localizationProvider: LocalizationProvider) {
        self.data = data
        self.localizationProvider = localizationProvider
    }

    func build() throws -> DashlaneSixTrayAlert {

        let title = try self.generateTitle(for: data, and: localizationProvider)
        let description = try self.generateDescription(for: data, and: localizationProvider)
        let details = try self.generateDetails(for: data, and: localizationProvider)
        let recommendation = try self.generateRecommendation(for: data, and: localizationProvider)
        let buttons = try self.generateButtons(for: data, and: localizationProvider)
        let timestamp = try self.generateTimestamp(for: data, and: localizationProvider)
        let date = try self.generateDate(for: data, and: localizationProvider)

        return DashlaneSixTrayAlert(title: title,
                                    description: description,
                                    details: details,
                                    recommendation: recommendation,
                                    buttons: buttons,
                                    timestamp: timestamp,
                                    date: date,
                                    data: data)
    }
}

extension DashlaneSixTrayAlertBuilder {

            func generateDescription(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {

        guard alertData.alertType.isDataLeakAlert else {
                        return nil
        }

                guard let impactedEmails = breach.impactedEmails?.joined(separator: ", ") else {
            throw AlertGenerator.AlertError.breachDoesNotHaveImpactedEmail
        }

        guard let domains = breach.domains?.joined(separator: ", ") else {
            throw AlertGenerator.AlertError.breachDoesNotHaveALinkedDomain
        }

        return AlertSection(title: AlertSection.Title(localizationProvider.localizedString(for: .trayDataLeakDescription)),
                            contents: [domains, impactedEmails])
    }
}

extension DashlaneSixTrayAlertBuilder {

    func generateRecommendation(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {

        let details = AlertBuildersUtils.CompromisedAccountsRecommendation(onlyPIIsCompromisedKey: .trayRecommendationOnlyPII,
                                                                           noPasswordCompromisedKey: .trayRecommendationNoPassword,
                                                                           oneCompromisedKey: .trayRecommendationYesSingle,
                                                                           multipleCompromisedKey: .trayRecommendationYesMultiple)
        return try AlertBuildersUtils.generateCompromisedAccountsRecommendation(for: alertData, and: localizationProvider, details: details)
    }
}

extension DashlaneSixTrayAlertBuilder {

    func generateButtons(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> Buttons {

                        if alertData.numberOfCompromisedCredentials == 0 {
            return Buttons(left: nil, right: .close)
        }

                if alertData.alertType.isDataLeakAlert {
            return Buttons(left: nil, right: .takeAction)
        }

        return Buttons(left: nil, right: .view)
    }
}
