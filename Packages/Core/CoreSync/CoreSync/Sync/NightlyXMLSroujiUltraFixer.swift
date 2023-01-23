import Foundation
import DashTypes

public struct NightlyXMLSroujiUltraFixer {
    let apiClient: DeprecatedCustomAPIClient
    let cryptoEngine: CryptoEngine
    private let userDefaultsCompletedKey = "nightlyXMLFixed"
    
    public init(apiClient: DeprecatedCustomAPIClient, cryptoEngine: CryptoEngine) {
        self.apiClient = apiClient
        self.cryptoEngine = cryptoEngine
    }
    
    public func doTheMagic() async throws  {
        guard Bundle.main.isNightly, !UserDefaults.standard.bool(forKey: userDefaultsCompletedKey) else {
            return
        }
        
        let getLatestResult = try await GetLatestDataService(apiClient: apiClient).latestData(fromTimestamp: .distantPast)
        let newLineAndSpaces = "\n\\s+"

        let cleanedTransactions = try getLatestResult.transactions.compactMap { transaction throws -> UploadTransaction? in
            guard let raw = transaction.content,
                  let type = transaction.type,
                  let base64Data = Data(base64Encoded: raw),
                  let decrypted = try? base64Data.decrypt(using: cryptoEngine).decompressQtCompressedData(),
                  let original = String(data: decrypted, encoding: .utf8) else {
                      return nil
                  }
            
                        let options: NSRegularExpression.Options = [.caseInsensitive, .dotMatchesLineSeparators]
            var cleaned = try original.replacingRegex(matching: ">\(newLineAndSpaces)<!\\[CDATA\\[", findingOptions: options, with: "><![CDATA[")
            cleaned = try cleaned.replacingRegex(matching: "\\]\\]>\(newLineAndSpaces)<", findingOptions: options, with: "]]><")
            
                        if cleaned.contains("key=\"\(type.keysToCheck)\"><![CDATA[\n") {
                cleaned = try cleaned.replacingRegex(matching: "<!\\[CDATA\\[\(newLineAndSpaces)", findingOptions: .caseInsensitive, with: "<![CDATA[")
                cleaned = try cleaned.replacingRegex(matching: "\(newLineAndSpaces)\\]\\]>", findingOptions: .caseInsensitive, with: "]]>")
            }

            guard cleaned != original else {
                return nil
            }

            let encrypted = try cleaned.toQtCompressedData().encrypt(using: cryptoEngine)
            return UploadTransaction(action: .edit, content: encrypted.base64EncodedString(), identifier: transaction.identifier, type: .init(rawValue: transaction.$type))
        }
        
        guard !cleanedTransactions.isEmpty else {
            UserDefaults.standard.set(true, forKey: userDefaultsCompletedKey)
            return
        }
        
        let _ = try await UploadContentService(apiClient: apiClient).upload(.init(timestamp: getLatestResult.timestamp, transactions: cleanedTransactions))
        UserDefaults.standard.set(true, forKey: userDefaultsCompletedKey)
    }
}


private extension PersonalDataContentType {
    var keysToCheck: String {
        switch self {
            case .settings:
                return "SyncBackup"
            case .dataChangeHistory:
                return "Removed"
            case .securityBreach:
                return "BreachId"
            case .secureFileInfo:
                return "CryptoKey"
            case .generatedPassword:
                return "Platform"
            default:
                return "AnonId"
        }
    }
}

extension String {
    func replacingRegex(
        matching pattern: String,
        findingOptions: NSRegularExpression.Options = .caseInsensitive,
        replacingOptions: NSRegularExpression.MatchingOptions = [],
        with template: String
    ) throws -> String {
        
        let regex = try NSRegularExpression(pattern: pattern, options: findingOptions)
        let range = NSRange(startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, options: replacingOptions, range: range, withTemplate: template)
    }
}

fileprivate extension Bundle {
    var isNightly: Bool {
        (infoDictionary?["DLBuildInformationDetails"] as? String) == "Nightly build"
    }
}
