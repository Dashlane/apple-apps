import Foundation

public extension PremiumStatus {
    func isSSOUser() -> Bool {
        return spaces?.contains(where: { $0.isSSOUser == true }) ?? false
    }

            func disabledWebsites() -> [String] {
        return (spaces ?? [])
            .map { $0.info.autologinDomainDisabledArray }
            .compactMap { $0 }
            .flatMap { $0 }
    }
}
