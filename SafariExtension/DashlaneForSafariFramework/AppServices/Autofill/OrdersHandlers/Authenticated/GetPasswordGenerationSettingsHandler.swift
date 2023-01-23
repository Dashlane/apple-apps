import Foundation
import DashlaneAppKit
import CoreSettings
import DashTypes

struct GetPasswordGenerationSettingsHandler: MaverickOrderHandleable, SessionServicesInjecting {

    typealias Request = MaverickEmptyRequest

    struct Response: MaverickOrderResponse {
        let id: String
        let length: UInt
        let letters: Bool
        let digits: Bool
        let symbols: Bool
        let avoidAmbiguous: Bool
    }

    let maverickOrderMessage: MaverickOrderMessage
    let userSettings: UserSettings

    init(maverickOrderMessage: MaverickOrderMessage, userSettings: UserSettings) {
        self.maverickOrderMessage = maverickOrderMessage
        self.userSettings = userSettings
    }

    func performOrder() throws -> Response? {

        let settings:PasswordGeneratorPreferences = userSettings.getPasswordGeneratorPreferences() ?? PasswordGeneratorPreferences()

        return Response(id: actionMessageID,
                        length: UInt(settings.length),
                        letters: settings.shouldContainLetters,
                        digits: settings.shouldContainDigits,
                        symbols: settings.shouldContainSymbols,
                        avoidAmbiguous: !settings.allowSimilarCharacters)

    }
}
