import Foundation
import DashTypes
import DashlaneAPI

extension APIConfiguration.Environment {
    public static var `default`: APIConfiguration.Environment {
#if DEBUG
        return .production

                #else
        return .production
#endif
    }
}

extension LegacyWebServiceImpl.Configuration.Environment {
    public static var `default`: LegacyWebServiceImpl.Configuration.Environment {
#if DEBUG
        return .production

                                                #else
        return .production
#endif
    }
}
