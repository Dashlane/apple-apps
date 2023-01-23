import Foundation
import DashTypes
import DashlaneReportKit

struct MaverickUsageLogHandler: MaverickOrderHandleable, SessionServicesInjecting {

    typealias Request = MaverickEmptyRequest
    typealias Response = MaverickEmptyResponse

    let maverickOrderMessage: MaverickOrderMessage
    let usageLogService: UsageLogService
    let logger: Logger

    init(maverickOrderMessage: MaverickOrderMessage, usageLogService: UsageLogService, logger: Logger) {
        self.maverickOrderMessage = maverickOrderMessage
        self.usageLogService = usageLogService
        self.logger = logger
    }

    func performOrder() throws -> Response? {
        DispatchQueue.global(qos: .background).async {
            self.decodeMessageAndSendLogs()
        }
        return nil
    }

    private func decodeMessageAndSendLogs() {
        guard let data = maverickOrderMessage.request?.data(using: .utf8),
            let mainDictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let code = mainDictionary["code"] as? Int,
            let precisions = mainDictionary["precisions"] as? [String: Any] else {
                return
        }

        do {
            let log = try decode(code: code, precisions: precisions)
            self.usageLogService.post(log)
            logger.debug("\(log)")
        } catch {
            logger.error("Wrong request code \(code) - precision \(precisions)")
        }
    }

    private func decode(code: Int, precisions: [String: Any]) throws -> LogCodeProtocol {
        switch code {
            case 4:
                guard let precision: UsageLogCode4Autologin = decodePrecisions(data: cleanContext(from: precisions)) else {
                    throw MaverickRequestHandlerError.wrongRequest
                }
                return precision
            case 5:
                guard let precision: UsageLogCode5Autofill = decodePrecisions(data: precisions.jsonData) else {
                    throw MaverickRequestHandlerError.wrongRequest
                }
                return precision
            case 6:
                guard let precision: UsageLogCode6SavePassword = decodePrecisions(data: cleanContext(from: precisions)) else {
                    throw MaverickRequestHandlerError.wrongRequest
                }
                return precision
            case 7:
                guard let precision: UsageLogCode7GeneratedPassword = decodePrecisions(data: cleanContext(from: precisions)) else {
                    throw MaverickRequestHandlerError.wrongRequest
                }
                return precision
            case 33:
                guard let precision: UsageLogCode33MessageBox = decodePrecisions(data: cleanContext(from: precisions)) else {
                    throw MaverickRequestHandlerError.wrongRequest
                }
                return precision
            case 76:
                guard let precision: UsageLogCode76Learningmetrics = decodePrecisions(data: fixLearningMetrics(from: precisions)) else {
                    throw MaverickRequestHandlerError.wrongRequest
                }
                return precision
            default:
                throw MaverickRequestHandlerError.wrongRequest
        }
    }

    private func decodePrecisions<Precision: Decodable>(data: Data) -> Precision? {
        do {
            return try JSONDecoder().decode(Precision.self, from: data)
        } catch {
            logger.debug("Error decoding precision \(String(data: data, encoding: .utf8) ?? "- no precision")")
        }
        return nil
    }

    private func cleanContext(from dictionary: [String: Any]) -> Data {
        var mutableDictionary = dictionary
        if let context = mutableDictionary["context"] as? String, context.isEmpty {
            mutableDictionary.removeValue(forKey: "context")
        }
        return mutableDictionary.jsonData
    }

    private func fixLearningMetrics(from dictionary: [String: Any]) -> Data {
        var mutableDictionary = dictionary
        if let index = mutableDictionary["index"] as? String, let intIndex = Int(index) {
            mutableDictionary["index"] = intIndex
        }
        if let filled = mutableDictionary["filled"] as? String {
            mutableDictionary["filled"] = Bool(filled) ?? false
        }
        if let filled = mutableDictionary["filledbyuser"] as? String {
            mutableDictionary["filledbyuser"] = Bool(filled) ?? false
        }
        return mutableDictionary.jsonData
    }
}

private extension Dictionary {
    var jsonData: Data {
        (try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)) ?? Data()
    }
}
