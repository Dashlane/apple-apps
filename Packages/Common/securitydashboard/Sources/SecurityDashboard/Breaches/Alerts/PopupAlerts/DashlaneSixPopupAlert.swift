import Foundation

public struct DashlaneSixPopupAlert: PopupAlertProtocol {

    public let title: String
    public let description: AlertSection?
    public let details: AlertSection?
    public let recommendation: AlertSection?

    public let buttons: Buttons

    public let data: AlertGenerator.AlertData
}

struct DashlaneSixPopupAlertBuilder: PopupAlertBuilderProtocol {

    let data: AlertGenerator.AlertData
    let localizationProvider: LocalizationProvider

    init(data: AlertGenerator.AlertData, localizationProvider: LocalizationProvider) {
        self.data = data
        self.localizationProvider = localizationProvider
    }

    func build() throws -> DashlaneSixPopupAlert {

        let title = try self.generateTitle(for: data, and: localizationProvider)
        let description = try self.generateDescription(for: data, and: localizationProvider)
        let details = try self.generateDetails(for: data, and: localizationProvider)
        let recommendation = try self.generateRecommendation(for: data, and: localizationProvider)
        let buttons = try self.generateButtons(for: data, and: localizationProvider)

        return DashlaneSixPopupAlert(title: title,
                                     description: description,
                                     details: details,
                                     recommendation: recommendation,
                                     buttons: buttons,
                                     data: data)
    }
}

extension DashlaneSixPopupAlertBuilder {

    func generateDescription(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {

        guard let domains = breach.domains?.joined(separator: ", ") else {
            throw AlertGenerator.AlertError.breachDoesNotHaveALinkedDomain
        }

        guard let breachDate = breach.eventDate?.readableString else {
            throw AlertGenerator.AlertError.breachDoesNotHaveAnEventDate
        }

        if alertData.alertType.isDataLeakAlert {
            guard let impactedEmails = breach.impactedEmails?.joined(separator: ", ") else {
                throw AlertGenerator.AlertError.breachDoesNotHaveImpactedEmail
            }
            return AlertSection(title: AlertSection.Title(localizationProvider.localizedString(for: .popupDataLeakDescription)),
                                contents: [domains, breachDate, impactedEmails])
        } else {
            return AlertSection(title: AlertSection.Title(localizationProvider.localizedString(for: .popupRegularDescription)),
                                contents: [domains, breachDate])
        }
    }
}

extension DashlaneSixPopupAlertBuilder {

    func generateRecommendation(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {

        let details = AlertBuildersUtils.CompromisedAccountsRecommendation(onlyPIIsCompromisedKey: .popupRecommendationOnlyPII,
                                                                           noPasswordCompromisedKey: .popupRecommendationNoPassword,
                                                                           oneCompromisedKey: .popupRecommendationYesSingle,
                                                                           multipleCompromisedKey: .popupRecommendationYesMultiple)
        return try AlertBuildersUtils.generateCompromisedAccountsRecommendation(for: alertData, and: localizationProvider, details: details)
    }
}

extension DashlaneSixPopupAlertBuilder {

    func generateButtons(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> Buttons {

                        if alertData.numberOfCompromisedCredentials == 0 {
            return Buttons(left: nil, right: .close)
        }

        return Buttons(left: .close, right: .view)
    }
}
