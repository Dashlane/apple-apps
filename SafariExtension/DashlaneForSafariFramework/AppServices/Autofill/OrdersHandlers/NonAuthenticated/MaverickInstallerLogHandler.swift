import Foundation

struct MaverickInstallerLogHandler: MaverickOrderHandleable {

    struct Request: Decodable {
        let step: MaverickInstallerLogger.LogStep
        let precisions: MaverickInstallerLogger.Precision
    }

    typealias Response = MaverickEmptyResponse

    let maverickOrderMessage: MaverickOrderMessage
    let maverickInstallerLogger: MaverickInstallerLogger

    func performOrder() throws -> Response? {
        guard let request: Request = self.maverickOrderMessage.content() else {
            throw MaverickRequestHandlerError.wrongRequest
        }

        maverickInstallerLogger.post(step: request.step, precisions: request.precisions)

        return nil
    }
}
