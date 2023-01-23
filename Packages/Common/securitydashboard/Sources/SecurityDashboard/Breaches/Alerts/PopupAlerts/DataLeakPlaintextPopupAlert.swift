import Foundation

public struct DataLeakPlaintextPopupAlert: PopupAlertProtocol {

    public let title: String
    public let description: AlertSection?
    public let details: AlertSection?
    public let recommendation: AlertSection?

    public let date: AlertSection?

    public let buttons: Buttons

    public let data: AlertGenerator.AlertData
}

struct DataLeakPlaintextPopupAlertBuilder: PopupAlertBuilderProtocol {

    let data: AlertGenerator.AlertData
    let localizationProvider: LocalizationProvider

    init(data: AlertGenerator.AlertData, localizationProvider: LocalizationProvider) {
        self.data = data
        self.localizationProvider = localizationProvider
    }

    func build() throws -> DataLeakPlaintextPopupAlert {

        let title = try self.generateTitle(for: data, and: localizationProvider)
        let details = try self.generateDetails(for: data, and: localizationProvider)
        let recommendation = try self.generateRecommendation(for: data, and: localizationProvider)
        let date = try self.generateDate(for: data, and: localizationProvider)
        let buttons = try self.generateButtons(for: data, and: localizationProvider)

		return DataLeakPlaintextPopupAlert(title: title,
										   description: nil,
										   details: details,
										   recommendation: recommendation,
										   date: date,
										   buttons: buttons,
										   data: data)
    }
}

extension DataLeakPlaintextPopupAlertBuilder {

    func generateTitle(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> String {
        if alertData.numberOfCompromisedCredentials == 0 {
            return localizationProvider.localizedString(for: .popupDataLeakTitleNoDomainNoMatch)
        }
        return localizationProvider.localizedString(for: .popupDataLeakNewTitle)
    }
}

extension DataLeakPlaintextPopupAlertBuilder {

    func generateDescription(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {
        return nil
    }

}

extension DataLeakPlaintextPopupAlertBuilder {

    func generateDetails(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {

        guard !alertData.impactedCredentials.isEmpty else {
            return nil
        }

                let maximumNumberOfElements = 5
        let emails = Set((alertData.impactedCredentials.compactMap({ $0.email }) + (alertData.breach.impactedEmails ?? []))
            .filter({ !$0.isEmpty })
            .prefix(maximumNumberOfElements))
        let affectedEmails = String(format: localizationProvider.localizedString(for: .popupBreachDetailsEmails), emails.joined(separator: ", "))

        let passwordsPlaceholder = "••••••••••••••••••"
		let affectedPasswords: String? = {
						guard alertData.impactedCredentials.isEmpty else {
				return nil
			}
			return String(format: localizationProvider.localizedString(for: .popupAffectedPasswords), passwordsPlaceholder)
		}()

        let message = [
            affectedEmails,
			affectedPasswords
			]
			.compactMap({ $0 })
			.joined(separator: "\n\n")

        let allContent = emails + [passwordsPlaceholder]

        return AlertSection(title: .init(message), contents: allContent)
    }
}

extension DataLeakPlaintextPopupAlertBuilder {

    func generateRecommendation(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {
                guard !alertData.impactedCredentials.isEmpty else {
            return noCredentialImpactedRecommendation(for: alertData, and: localizationProvider)
        }
        let parameter = alertData.impactedCredentials.count
        let recommendation = String(format: localizationProvider.localizedString(for: .popupAffectedPasswordsMatchingCredentialsRecommandation), parameter)
        return AlertSection(title: .init(recommendation), contents: ["\(parameter)"])
    }

    func noCredentialImpactedRecommendation(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) -> AlertSection? {
        guard let parameter = alertData.breach.impactedEmails?.first, alertData.impactedCredentials.isEmpty else {
            return nil
        }

        let recommendation = String(format: localizationProvider.localizedString(for: .popupRecommendationDataLeakNoDomainNoPassword), parameter)
        return AlertSection(title: .init(recommendation), contents: ["\(parameter)"])
    }
}

extension DataLeakPlaintextPopupAlertBuilder {

    func generateButtons(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> Buttons {
        if alertData.impactedCredentials.isEmpty {
            return Buttons(left: .dismiss, right: .viewDetails)
        }
        return Buttons(left: .later, right: .takeAction)
    }
}

extension DataLeakPlaintextPopupAlertBuilder {
    func generateDate(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {
        guard let breachCreationDate = breach.eventDate?.readableString else {
            return nil
        }
        return AlertSection(title: AlertSection.Title(localizationProvider.localizedString(for: .trayDate)),
                            contents: [breachCreationDate])
    }
}
