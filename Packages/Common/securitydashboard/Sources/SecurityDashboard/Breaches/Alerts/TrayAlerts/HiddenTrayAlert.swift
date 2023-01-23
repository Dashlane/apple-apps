import Foundation

public struct HiddenTrayAlert: TrayAlertProtocol {

    public let title: String
    public let description: AlertSection?
    public let details: AlertSection?
    public let recommendation: AlertSection?

    public let buttons: Buttons

    public let timestamp: String?
    public let date: AlertSection?

    public let data: AlertGenerator.AlertData
}

struct HiddenTrayAlertBuilder: TrayAlertBuilderProtocol {

    let data: AlertGenerator.AlertData
    let localizationProvider: LocalizationProvider

    init(data: AlertGenerator.AlertData, localizationProvider: LocalizationProvider) {
        self.data = data
        self.localizationProvider = localizationProvider
    }

    func build() throws -> HiddenTrayAlert {

        let title = try self.generateTitle(for: data, and: localizationProvider)
        let details = try self.generateDetails(for: data, and: localizationProvider)
        let recommendation = try self.generateRecommendation(for: data, and: localizationProvider)
        let buttons = try self.generateButtons(for: data, and: localizationProvider)
        let timestamp = try self.generateTimestamp(for: data, and: localizationProvider)
        let date = try self.generateDate(for: data, and: localizationProvider)

        return HiddenTrayAlert(title: title,
                        description: nil,
                        details: details,
                        recommendation: recommendation,
                        buttons: buttons,
                        timestamp: timestamp,
                        date: date,
                        data: data)
    }
}

extension HiddenTrayAlertBuilder {

	func generateTitle(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> String {
		return localizationProvider.localizedString(for: .trayDataLeakNewTitle)
	}
}

extension HiddenTrayAlertBuilder {
    func generateRecommendation(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> AlertSection? {
        return AlertSection(title: AlertSection.Title(localizationProvider.localizedString(for: .trayRecommendationGoPremium)),
                            contents: [])
    }
}

extension HiddenTrayAlertBuilder {
    func generateButtons(for alertData: AlertGenerator.AlertData, and localizationProvider: LocalizationProvider) throws -> Buttons {
        return Buttons(left: nil, right: .upgrade)
    }
}
