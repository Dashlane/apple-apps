import Foundation

public extension Sequence where Element == OTPInfo {
    func sortedByIssuer() -> [OTPInfo] {
        sorted(by: {
            let lhsTitle = $0.configuration.issuerOrTitle.lowercased()
            let rhsTitle = $1.configuration.issuerOrTitle.lowercased()
            guard lhsTitle == rhsTitle else {
                                return lhsTitle < rhsTitle
            }
            let lhsLogin = $0.configuration.login.lowercased()
            let rhsLogin = $1.configuration.login.lowercased()
            guard lhsLogin == rhsLogin else {
                                return lhsLogin < rhsLogin
            }
                        return $0.configuration.type.rawValue < $1.configuration.type.rawValue
        })
    }
}
