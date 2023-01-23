import Foundation

public struct DataLeakUpsellPremiumPlusPopupAlert: PopupAlertProtocol {
    public let title: String
    public let description: AlertSection?
    public let details: AlertSection?
    public let recommendation: AlertSection?

    public let explanations: AlertSection?

    public let buttons: Buttons

    public let data: AlertGenerator.AlertData
}

struct DataLeakUpsellPremiumPlusPopupAlertBuilder: PopupAlertBuilderProtocol {

    let data: AlertGenerator.AlertData
    let localizationProvider: LocalizationProvider

    init(data: AlertGenerator.AlertData, localizationProvider: LocalizationProvider) {
        self.data = data
        self.localizationProvider = localizationProvider
    }

    func build() throws -> DataLeakUpsellPremiumPlusPopupAlert {
        let title = try self.generateTitle(for: data, and: localizationProvider)
        let description = try self.generateDescription(for: data, and: localizationProvider)
        let details = try self.generateDetails(for: data, and: localizationProvider)
        let explanations = try self.generateExplanations(for: data, and: localizationProvider)
        let buttons = try self.generateButtons(for: data, and: localizationProvider)

        return DataLeakUpsellPremiumPlusPopupAlert(title: title,
                                         description: description,
                                         details: details,
                                         recommendation: nil,
                                         explanations: explanations,
                                         buttons: buttons,
                                         data: data)
    }
}

extension DataLeakUpsellPremiumPlusPopupAlertBuilder {
    func generateDescription(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {
        return nil
    }
}

extension DataLeakUpsellPremiumPlusPopupAlertBuilder {

                                                    func generateDetails(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {

        let details = AlertBuildersUtils.UserDataDetails(emailsKey: .popupBreachDetailsEmails,
                                                         domainsKey: .popupBreachDetailsDomains,
                                                         usernamesKey: .popupBreachDetailsUsernames)

        switch (alertData.breach.containsPII, alertData.breach.leaksPassword) {
        case (false, true):
            return try AlertBuildersUtils.generateUserDataDetails(for: alertData, and: localizationProvider, using: details)
        case (true, false):
            let details = AlertBuildersUtils.DataInvolvedDetails(titleKey: .popupBreachDetails)
            return try AlertBuildersUtils.generateDataInvolvedDetails(for: alertData, and: localizationProvider, details: details)
        case (true, true):
            let dataInvolvedDetails = AlertBuildersUtils.DataInvolvedDetails(titleKey: .popupBreachDetails)
            return try AlertBuildersUtils.generateUserDataDetails(for: alertData, and: localizationProvider, using: details, and: dataInvolvedDetails)
        default:
            return nil
        }
    }
}

extension DataLeakUpsellPremiumPlusPopupAlertBuilder {

    func generateExplanations(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection {

        let type: LocalizationKey = alertData.breach.leaksPassword ? .popupExplanationsDataLeakPremiumPlusUpsellDescription : .popupExplanationsDataLeakPremiumPlusUpsellDescriptionOnlyPIIs

        return AlertSection(title: .init(localizationProvider.localizedString(for: type)),
                            contents: [])
    }
}

extension DataLeakUpsellPremiumPlusPopupAlertBuilder {

    func generateButtons(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> Buttons {

                        if alertData.breach.containsPII && !alertData.breach.leaksPassword {
            return Buttons(left: [.dismiss], right: [])
        }

        return Buttons(left: [.dismiss], right: [.takeAction])
    }
}
