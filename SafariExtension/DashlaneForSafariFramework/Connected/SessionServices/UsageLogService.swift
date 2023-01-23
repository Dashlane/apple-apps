import Foundation
import DashlaneReportKit
import CoreNetworking
import CoreSession
import DashTypes
import DashlaneCrypto
import SwiftTreats
import DashlaneAppKit

protocol UsageLogServiceProtocol {
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?)
    var teamSpaceLogger: TeamSpacesUsageLogger { get }
}

extension UsageLogServiceProtocol {
    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>? = nil) {
        post(log, completion: completion)
    }
}

class UsageLogService: UsageLogServiceProtocol {
    
    private let engine: LogEngine

    var teamSpaceLogger: TeamSpacesUsageLogger {
        TeamSpacesUsageLogger(usageLogService: self)
    }
    
    init(logDirectory: URL,
         anonymousUserId: String,
         webservice: LegacyWebService,
         login: Login,
         anonymousDeviceId: String,
         cryptoService: CryptoEngine,
         logger: Logger) {

        let workingDirectory = FileManager.default.temporaryDirectory
        let reportLogInfo = UsageLogInfo(
            userId: anonymousUserId,
            device: anonymousDeviceId,
            session: Int(Date().timeIntervalSince1970),
            platform: System.platform,
            version: Application.version(),
            osversion: System.version,
            usagePartnerId: ApplicationSecrets.Server.partnerId,
            sdkVersion: "",
            testRealUserId: login.isTest ? login.email : nil,
            sessionDirectory: workingDirectory)
        
        engine = LogEngine(reportLogInfo: reportLogInfo,
                           uploadWebService: webservice,
                           cryptoDelegate: cryptoService,
                           useLogTrigger: true,
                           localLogger: logger)
    }

    func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>? = nil) {
        engine.post(log, completion: completion)
    }
}

extension UsageLogService {
    private class FakeUsageLogService: UsageLogServiceProtocol {
        var teamSpaceLogger: TeamSpacesUsageLogger {
            TeamSpacesUsageLogger(usageLogService: self)
        }
        
        func post(_ log: LogCodeProtocol, completion: CompletionBlock<Bool, Error>?) {}
    }

    static var fakeService: UsageLogServiceProtocol {
        return FakeUsageLogService()
    }
}
