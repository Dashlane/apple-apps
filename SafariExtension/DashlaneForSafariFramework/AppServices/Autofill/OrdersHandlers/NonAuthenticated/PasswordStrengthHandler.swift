import Foundation
import CorePasswords

struct PasswordStrengthHandler: MaverickOrderHandleable {

    struct Request: Decodable {
        let password: String
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let strength: Int
    }

    let maverickOrderMessage: MaverickOrderMessage
    let passwordEvaluator: PasswordEvaluatorProtocol

    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }
        let evaluation = passwordEvaluator.evaluate(request.password)
        let score = evaluation.score

        return Response(id: actionMessageID, strength: score)
    }
}
