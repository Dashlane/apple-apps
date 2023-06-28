import Foundation

public struct AccountMigrationInfos {
    public let session: Session
    public let type: SSOMigrationType
    public let authTicket: AuthTicket?
}
