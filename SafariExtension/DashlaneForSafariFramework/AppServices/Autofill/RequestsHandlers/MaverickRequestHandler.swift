import Foundation

protocol MaverickRequestHandler {
    func performOrder(_ order: MaverickOrder) async throws -> Communication?
}

enum MaverickRequestHandlerError: Error {
    case wrongRequest
    case notImplemented
    case passwordSettingsMissing
}
