import Foundation

public protocol PasswordHealthResult {
	var credentials: [SecurityDashboardCredential] { get set }

        var elements: [SecurityDashboardCredential] { get set }

    	var count: Int { get }
    
        mutating func filter(bySpacedId: String?, sensitiveOnly: Bool)
}
