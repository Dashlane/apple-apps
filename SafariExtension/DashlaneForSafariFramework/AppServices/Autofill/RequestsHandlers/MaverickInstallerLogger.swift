import Foundation
import DashlaneReportKit

public struct MaverickInstallerLogger : DashlaneReportKit.LogSection {

    public let logEngine: DashlaneReportKit.LogEngineProtocol

    public enum LogStep: String, Decodable {
        case reactivationWebCardShown = "18.1"
        case reactivationWebCardClicked = "18.2"
        case reactivationWebCardClosed = "18.3"
        case reactivationWebCardDisabled = "18.4"
    }

    public struct Precision: Decodable {
        let domain: String?
        let type: String?
    }

    public init(logEngine: DashlaneReportKit.LogEngineProtocol) {
        self.logEngine = logEngine
    }

    public func post(step: LogStep, precisions: Precision) {
        let log = InstallerLogCode18Installer(step: step.rawValue, domain: precisions.domain, type: precisions.type)
        logEngine.post(log)
    }
}
