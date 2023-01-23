import Foundation

public protocol CredentialsProvider: AnyObject {
    var updater: IdentityDashboardCredentialsUpdates? { get set }
    func fetchCredentials() -> [SecurityDashboardCredential]
}

public protocol IdentityDashboardCredentialsUpdates: AnyObject {
    func refreshCredentials()
}
