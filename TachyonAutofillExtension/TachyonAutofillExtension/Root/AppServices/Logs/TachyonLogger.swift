import Foundation
import DashlaneReportKit

class TachyonLogger {

    let logEngine: LogEngine
    var sessionId: String
    init(engine: LogEngine) {
        self.logEngine = engine
        self.sessionId = UUID().uuidString
    }
    
        func log(_ event: TachyonLoggable) {
        let data = event.logData
        let log = InstallerLogCode38Installer38x(step: "38.6",
                                                 app_website: data.domain,
                                                 tachyon_session_id: sessionId,
                                                 type: data.type,
                                                 subtype: data.subType,
                                                 action: data.action,
                                                 subaction: data.subAction)
        logEngine.post(log)
    }
}
