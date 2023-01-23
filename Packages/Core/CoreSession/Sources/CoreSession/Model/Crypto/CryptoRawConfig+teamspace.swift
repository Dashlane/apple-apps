import DashTypes
import Foundation

extension CryptoRawConfig {
                        public init(fixedSalt: Data?,
                userParametersHeader: CryptoEngineConfigHeader,
                teamSpaceParametersHeader: CryptoEngineConfigHeader? = nil) {
        let fixedSalt = fixedSalt
        if let teamSpaceParametersHeader = teamSpaceParametersHeader?.trimmingCharacters(in: .whitespaces), !teamSpaceParametersHeader.isEmpty {
            self.init(fixedSalt: fixedSalt, parametersHeader: teamSpaceParametersHeader)
        } else {
            let parametersHeader = userParametersHeader.trimmingCharacters(in: .whitespaces)
            self.init(fixedSalt: fixedSalt, parametersHeader: parametersHeader)
        }
    }
}

public typealias CryptoEngineConfigHeader = String
