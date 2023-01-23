import Foundation
import CorePasswords
import DashTypes

struct GeneratePasswordHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {
        let length: Int
        let letters: Bool
        let digits: Bool
        let symbols: Bool
        let avoidAmbiguous: Bool

        var options: PasswordCompositionOptions {
            var compositionOptions = [PasswordCompositionOptions]()

            if letters {
                compositionOptions.append(contentsOf: [.lowerCaseLetters, .upperCaseLetters])
            }
            if digits {
                compositionOptions.append(.numerals)
            }
            if symbols {
                compositionOptions.append(.symbols)
            }

            return PasswordCompositionOptions(compositionOptions)
        }
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let password: String
        let strength: Int
    }

    let maverickOrderMessage: MaverickOrderMessage
    let passwordEvaluator: PasswordEvaluatorProtocol

    init(maverickOrderMessage: MaverickOrderMessage, passwordEvaluator: PasswordEvaluatorProtocol) {
        self.maverickOrderMessage = maverickOrderMessage
        self.passwordEvaluator = passwordEvaluator
    }

    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }

        let generatedPassword = PasswordGenerator(length: request.length,
                                                  composition: request.options,
                                                  distinguishable: request.avoidAmbiguous).generate()
        let evaluation = passwordEvaluator.evaluate(generatedPassword)
        return Response(id: actionMessageID, password: generatedPassword, strength: evaluation.strength.percentScore)
    }
}
