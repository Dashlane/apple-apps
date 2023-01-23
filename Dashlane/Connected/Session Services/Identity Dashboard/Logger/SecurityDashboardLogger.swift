import Foundation
import DashlaneReportKit
import CorePersonalData

struct SecurityDashboardLogger {
    typealias SubType = UsageLogCode125PasswordHealthDashboard.Type_subType

    let usageLogService: UsageLogServiceProtocol
    let type: SubType
    let spaceId: String?

    func logExclude(_ credential: Credential) {
        let log125 = UsageLogCode125PasswordHealthDashboard(type: .passwordHealth,
                                                            type_sub: type,
                                                            action: .exclude,
                                                            action_sub: nil,
                                                            security_score: nil,
                                                            website: credential.url?.domain?.name,
                                                            space_id: spaceId)
        usageLogService.post(log125)
    }

    func logInclude(_ credential: Credential) {
        let log125 = UsageLogCode125PasswordHealthDashboard(type: .passwordHealth,
                                                            type_sub: type,
                                                            action: .reintroduce,
                                                            action_sub: nil,
                                                            security_score: nil,
                                                            website: credential.url?.domain?.name,
                                                            space_id: spaceId)
        usageLogService.post(log125)
    }

    func logReplace(_ credential: Credential) {
        let log125 = UsageLogCode125PasswordHealthDashboard(type: .passwordHealth,
                                                            type_sub: type,
                                                            action: .replace,
                                                            action_sub: nil,
                                                            security_score: nil,
                                                            website: credential.url?.domain?.name,
                                                            space_id: spaceId)
        usageLogService.post(log125)
    }

    func logShow(forScore newScore: Int?, origin: String?) {

        guard let newScore = newScore else { return }

        let log125 = UsageLogCode125PasswordHealthDashboard(type: .passwordHealth,
                                                            type_sub: type,
                                                            action: .show,
                                                            action_sub: nil,
                                                            security_score: newScore,
                                                            space_id: spaceId,
                                                            origin: origin)
        usageLogService.post(log125)
    }

    func logOpenDetails(of credential: Credential) {
        let log125 = UsageLogCode125PasswordHealthDashboard(type: .passwordHealth,
                                                            type_sub: type,
                                                            action: .openDetails,
                                                            action_sub: nil,
                                                            security_score: nil,
                                                            website: credential.url?.domain?.name,
                                                            space_id: spaceId)
        usageLogService.post(log125)
    }

    func logUpdate(forScore newScore: Int?) {
                guard let newScore = newScore else { return }

        let log125 = UsageLogCode125PasswordHealthDashboard(type: .passwordHealth,
                                                            type_sub: type,
                                                            action: .update,
                                                            action_sub: nil,
                                                            security_score: newScore,
                                                            website: nil,
                                                            space_id: spaceId)
        usageLogService.post(log125)
    }

}

extension UsageLogService {
    func secyrityDashboardLogger(for type: SecurityDashboardLogger.SubType, spaceId: String) -> SecurityDashboardLogger {
        return SecurityDashboardLogger(usageLogService: self, type: type, spaceId: spaceId)
    }
}
