import Foundation
import DashTypes
import SwiftTreats

public struct PersonalDataURL: Codable, Equatable {
    public var rawValue: String
    public var domain: Domain?
    public var host: String?

    public init(rawValue: String, domain: Domain? = nil, host: String? = nil) {
        self.rawValue = rawValue
        self.domain = domain
        self.host = host
    }

    public static func == (lhs: PersonalDataURL, rhs: PersonalDataURL) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

                    public var displayDomain: String {
        if let domain = domain, !domain.name.isEmpty {
            return domain.name
        }
        if let url = openableURL, let hostname = url.host {
            return hostname
        }
        return rawValue
    }

    public var displayedScheme: String {
        guard let scheme =  openableURL?.scheme else {
            return ""
        }
        return scheme + "://"
    }

    public var openableURL: URL? {
        return rawValue.openableURL
    }
}

extension PersonalDataURL {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}
