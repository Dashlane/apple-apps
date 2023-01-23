import Foundation

public struct DataLeakPlaintextTrayAlert: TrayAlertProtocol {

    public let title: String
    public let description: AlertSection?
    public let details: AlertSection?
    public let recommendation: AlertSection?

    public let leakedPasswords: AlertSection?
    public var everyLeakedPasswords: Set<BreachesService.Password> {
        return data.leakedPasswords
    }

    public let buttons: Buttons

    public let timestamp: String?
    public let date: AlertSection?

    public let data: AlertGenerator.AlertData
}

struct DataLeakPlaintextTrayAlertBuilder: TrayAlertBuilderProtocol {

    let data: AlertGenerator.AlertData
    let localizationProvider: LocalizationProvider

    init(data: AlertGenerator.AlertData, localizationProvider: LocalizationProvider) {
        self.data = data
        self.localizationProvider = localizationProvider
    }

    func build() throws -> DataLeakPlaintextTrayAlert {

        let title = try self.generateTitle(for: data, and: localizationProvider)
        let buttons = try self.generateButtons(for: data, and: localizationProvider)
        let timestamp = try self.generateTimestamp(for: data, and: localizationProvider)
        let date = try self.generateDate(for: data, and: localizationProvider)
        let details = try self.generateDetails(for: data, and: localizationProvider)
        let leakedPasswords = try self.generateLeakedPasswordsString(for: data, and: localizationProvider)
        let recommendation = try self.generateRecommendation(for: data, and: localizationProvider)

        return DataLeakPlaintextTrayAlert(title: title,
										  description: nil,
										  details: details,
										  recommendation: recommendation,
										  leakedPasswords: leakedPasswords,
										  buttons: buttons,
										  timestamp: timestamp,
										  date: date,
										  data: data)
    }
}

extension DataLeakPlaintextTrayAlertBuilder {

    func generateTitle(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> String {
        return String(format: localizationProvider.localizedString(for: .trayDataLeakNewTitle))
    }
}

extension DataLeakPlaintextTrayAlertBuilder {

    func generateButtons(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> Buttons {
        if alertData.numberOfCompromisedCredentials == 0 {
            return Buttons(left: nil, right: .close)
        }
        return Buttons(left: nil, right: .view)
    }
}

extension DataLeakPlaintextTrayAlertBuilder {

    func generateDetails(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {

        guard !alertData.impactedCredentials.isEmpty else {
            return nil
        }

                let maximumNumberOfElements = 5
        let emails = Set((alertData.impactedCredentials.compactMap({ $0.email }) + (alertData.breach.impactedEmails ?? []))
            .filter({ !$0.isEmpty })
            .prefix(maximumNumberOfElements))
        let affectedEmails = String(format: localizationProvider.localizedString(for: .popupBreachDetailsEmails), emails.joined(separator: ", "))

        return AlertSection(title: .init(affectedEmails), contents: [String](emails))
    }
}

extension DataLeakPlaintextTrayAlertBuilder {

    func generateLeakedPasswordsString(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {
                guard alertData.alertType == .dataLeakAlertWithLeakedData, alertData.numberOfCompromisedCredentials > 0 else { return nil }
                guard alertData.impactedCredentials.isEmpty else { return nil }

        let joinedPasswords = alertData.leakedPasswords.joined(separator: ", ")
        let string =  String(format: localizationProvider.localizedString(for: .trayAffectedPasswords), joinedPasswords)
        return AlertSection(title: .init(string), contents: [String](alertData.leakedPasswords))
    }
}

extension DataLeakPlaintextTrayAlertBuilder {
    
    func generateRecommendation(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {
                guard !alertData.impactedCredentials.isEmpty else {
            return noCredentialImpactedRecommendation(for: alertData, and: localizationProvider)
        }
        let parameter = alertData.impactedCredentials.count
        let recommendation = String(format: localizationProvider.localizedString(for: .trayAffectedPasswordsMatchingCredentialsRecommandation), parameter)
        return AlertSection(title: .init(recommendation), contents: ["\(parameter)"])
    }
    
    func noCredentialImpactedRecommendation(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) -> AlertSection? {
        guard let parameter = alertData.breach.impactedEmails?.first, alertData.impactedCredentials.isEmpty else {
            return nil
        }
        
        let recommendation = String(format: localizationProvider.localizedString(for: .trayRecommendationDataLeakNoDomainNoPassword), parameter)
        return AlertSection(title: .init(recommendation), contents: ["\(parameter)"])
    }
}
