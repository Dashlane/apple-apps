import Foundation
import CorePasswords
import DashTypes

struct EvaluatePasswordHandler: MaverickOrderHandleable, SessionServicesInjecting {

    struct Request: Decodable {
        let password: String
    }

    struct Response: MaverickOrderResponse {
        let id: String
        let score: Int
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

        let evaluation = passwordEvaluator.evaluate(request.password)
        return Response(id: actionMessageID, score: evaluation.percentScore)
    }
}
