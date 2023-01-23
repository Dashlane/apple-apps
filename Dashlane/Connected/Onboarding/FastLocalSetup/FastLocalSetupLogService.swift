import Foundation
import DashlaneReportKit

struct FastLocalSetupLogService {

    enum Event: String {
        case shownInLogin
        case touchIDEnabled
        case touchIDDisabled
        case faceIDEnabled
        case faceIDDisabled
        case masterPasswordResetEnabled
        case masterPasswordResetDisabled

        var action: String {
            return self.rawValue
        }
    }

    let usageLogService: UsageLogServiceProtocol

    func log(_ event: Event) {
        let log = UsageLogCode75GeneralActions(type: "fastLocalSetup",
                                               action: event.action)

        self.usageLogService.post(log)
    }
}

extension UsageLogServiceProtocol {
    var fastLocalSetupLogService: FastLocalSetupLogService {
        return FastLocalSetupLogService(usageLogService: self)
    }
}

extension FastLocalSetupLogService {
    static var fakeService: FastLocalSetupLogService {
        FastLocalSetupLogService(usageLogService: UsageLogService.fakeService)
    }
}
