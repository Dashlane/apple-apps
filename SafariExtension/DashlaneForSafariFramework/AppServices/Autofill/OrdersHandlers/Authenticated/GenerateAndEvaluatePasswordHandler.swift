import Foundation
import CorePasswords
import CorePersonalData
import DomainParser
import DashTypes
import DashlaneAppKit
import CoreSettings

struct GenerateAndEvaluatePasswordHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {

        struct Composition: Decodable {
            let length: Int
            let letters: Bool
            let numbers: Bool
            let symbols: Bool

            var options: PasswordCompositionOptions {
                var compositionOptions = [PasswordCompositionOptions]()

                if letters {
                    compositionOptions.append(contentsOf: [.lowerCaseLetters, .upperCaseLetters])
                }
                if numbers {
                    compositionOptions.append(.numerals)
                }
                if symbols {
                    compositionOptions.append(.symbols)
                }

                return PasswordCompositionOptions(compositionOptions)
            }
        }

        let domain: String
        let composition: Composition?

        enum CodingKeys: String, CodingKey {
            case domain
            case length
            case letters
            case numbers
            case symbols
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.domain = try container.decode(String.self, forKey: .domain)

            if let length = try container.decodeIfPresent(Int.self, forKey: .length),
                let letters = try container.decodeIfPresent(Bool.self, forKey: .letters),
                let numbers = try container.decodeIfPresent(Bool.self, forKey: .numbers),
                let symbols = try container.decodeIfPresent(Bool.self, forKey: .symbols) {
                self.composition = Composition(length: length, letters: letters, numbers: numbers, symbols: symbols)
            } else {
                self.composition = nil
            }
        }
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let password: String
        let strength: Int
    }

    let maverickOrderMessage: MaverickOrderMessage
    let passwordEvaluator: PasswordEvaluatorProtocol
    let personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder
    let database: ApplicationDatabase
    let userSettings: UserSettings

    init(maverickOrderMessage: MaverickOrderMessage,
         passwordEvaluator: PasswordEvaluatorProtocol,
         personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder,
         database: ApplicationDatabase,
         userSettings: UserSettings) {
        self.maverickOrderMessage = maverickOrderMessage
        self.passwordEvaluator = passwordEvaluator
        self.personalDataURLDecoder = personalDataURLDecoder
        self.database = database
        self.userSettings = userSettings
    }

    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }

        let generatedPassword = try generatePassword(fromRequest: request, userSettings: userSettings)
        let score = passwordEvaluator.evaluate(generatedPassword).strength.score

        var generated = GeneratedPassword()
        generated.password = generatedPassword
        generated.domain = try personalDataURLDecoder.decodeURL(request.domain)
        generated.generatedDate = Date()
        generated.platform = System.platform

        try database.save(generated)

        return Response(id: actionMessageID, password: generatedPassword, strength: score)
    }

    private func generatePassword(fromRequest request: GenerateAndEvaluatePasswordHandler.Request, userSettings: UserSettings) throws -> String {
        if let composition = request.composition {
            return PasswordGenerator(length: composition.length,
                                     composition: composition.options,
                                     distinguishable: true).generate()
        } else if let settings = userSettings.getPasswordGeneratorPreferences() {
            let composition = Request.Composition(length: Int(settings.length),
                                                  letters: settings.shouldContainLetters,
                                                  numbers: settings.shouldContainDigits,
                                                  symbols: settings.shouldContainSymbols)
            return PasswordGenerator(length: composition.length,
                                     composition: composition.options,
                                     distinguishable: true).generate()
        }

        throw MaverickRequestHandlerError.passwordSettingsMissing
    }
}


extension UserSettings {
    func getPasswordGeneratorPreferences() -> PasswordGeneratorPreferences? {
        let preferences: PasswordGeneratorPreferences? = self[.passwordGeneratorPreferences]
        return preferences
    }
}
