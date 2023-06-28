import Foundation
import CoreSettings
import CorePremium
import DashlaneAppKit

extension UserEncryptedSettings {
    func premiumStatus() -> PremiumStatus? {
        guard let data: Data = self[.premiumStatusData] else {
            return nil
        }

        return try? PremiumStatusService.decoder.decode(PremiumStatus.self, from: data)
    }
}
