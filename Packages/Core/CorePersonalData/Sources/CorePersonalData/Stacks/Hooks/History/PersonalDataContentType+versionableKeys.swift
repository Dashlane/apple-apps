import Foundation
import DashTypes

extension PersonalDataContentType {
            var versionableKeys: Set<String> {
        switch self {
            case .credential:
                let keys: [Credential.CodingKeys] = [
                    .email,
                    .login,
                    .secondaryLogin,
                    .note,
                    .legacyOTPSecret,
                    .rawOTPURL,
                    .password,
                    .title,
                    .url,
                    .userSelectedUrl
                ]
                return Set(keys.map(\.rawValue))

            default:
                return []
        }
    }

    var historyTitleKey: String? {
        switch self {
            case .credential:
                return Credential.CodingKeys.title.rawValue
            default:
                return nil
        }
    }
}
