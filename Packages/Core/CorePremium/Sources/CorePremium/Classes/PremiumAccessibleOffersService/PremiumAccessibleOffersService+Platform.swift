import Foundation

extension PremiumAccessibleOffersService {
    struct Constants {
                #if os(iOS)
        static let platform = "ios"
        #else
        static let platform = "safari"
        #endif
    }
}
