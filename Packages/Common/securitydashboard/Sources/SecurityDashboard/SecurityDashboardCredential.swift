import Foundation

public enum PasswordStrength: Int {
	case veryUnsafe = 1
	case unsafe
	case notSoSafe
	case safe
	case superSafe
}

public protocol SecurityDashboardBreach {
    var id: String { get }
    var name: String { get }
    var eventDate: EventDate { get }
    var creationDate: Date { get }
    var kind: BreachKind { get }
}

public protocol SecurityDashboardCredential {
        var spaceId: String { get }

		var identifier: String { get }

		var password: String { get }

		var strength: PasswordStrength { get }

		var domain: String? { get }

		var sensitiveDomain: Bool { get }

				var disabledForPasswordAnalysis: Bool { get set }

				var compromisedIn: [SecurityDashboardBreach] { get set }

			var lastModificationDate: Date { get }

		var title: String { get }

        var email: String? { get }

        var username: String? { get }
}

extension SecurityDashboardCredential where Self: Equatable {
	func isEqualTo(_ other: SecurityDashboardCredential) -> Bool {
		return self.identifier == other.identifier
	}
}
