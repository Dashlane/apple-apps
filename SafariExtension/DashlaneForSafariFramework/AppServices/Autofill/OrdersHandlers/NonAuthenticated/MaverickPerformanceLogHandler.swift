import Foundation
import DashlaneReportKit
import Logger

struct MaverickPerformanceLogHandler: MaverickOrderHandleable {

    typealias Request = MaverickEmptyRequest
    typealias Response = MaverickEmptyResponse

    let maverickOrderMessage: MaverickOrderMessage
    let exceptionLogService: KibanaLogger
    let logEngine: LogEngine

    func performOrder() throws -> Response? {
        let logInfos = try self.infos(fromRequest: maverickOrderMessage.request)

        let report = try PerformanceLogCodeAnalysisReport(content: logInfos)
        exceptionLogService.post(report, logEngine: logEngine)

        return nil
    }

    func infos(fromRequest request: String?) throws -> [String: Any] {
        guard let request = request?.data(using: .utf8),
            let dictionaryRepresentation = try? JSONSerialization.jsonObject(with: request, options: .allowFragments) as? [String: Any],
            let content = dictionaryRepresentation["content"] as? [String: Any],
            let infos = content["info"] as? [String: Any] else {
                throw MaverickRequestHandlerError.wrongRequest
        }
        return infos
    }

}

private extension PerformanceLogCodeAnalysisReport {

    init(content: [String: Any]) throws {
        var mutableContent = content
        mutableContent["type"] = "AnalysisReport"
        let data = try JSONSerialization.data(withJSONObject: mutableContent, options: .fragmentsAllowed)
        let decoded = try JSONDecoder().decode(PerformanceLogCodeAnalysisReport.self, from: data)
        self = decoded
    }
}

extension KibanaLogger {

    func post(_ log: CodableLogCodeProtocol, logEngine: LogEngine) {
        logEngine.post(log)
    }

    
}
