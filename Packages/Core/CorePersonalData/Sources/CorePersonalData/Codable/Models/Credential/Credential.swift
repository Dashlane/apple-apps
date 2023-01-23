import Foundation
import DashTypes
import SwiftTreats

public struct Credential: PersonalDataCodable, Equatable, Identifiable, Categorisable, DatedPersonalData {
    public typealias CategoryType = CredentialCategory
    
    public static let contentType: PersonalDataContentType = .credential
    public static let searchCategory: SearchCategory = .credential
    
    public enum CodingKeys: String, CodingKey {
        case id
        case category
        case anonId
        case metadata
        case url
        case userSelectedUrl
        case useFixedUrl
        case trustedUrlGroup
        case login
        case secondaryLogin
        case title
        case password
        case email
        case note
        case autoLogin
        case numberOfUse = "numberUse"
        case lastUseDate = "lastUse"
        case passwordModificationDate = "modificationDatetime"
        case creationDatetime
        case userModificationDatetime
        case legacyOTPSecret = "otpSecret"
        case rawOTPURL = "otpUrl"
        case disabledForPasswordAnalysis = "checked"
        case spaceId
        case localeFormat
        case subdomainOnly
        case isProtected = "autoProtected"
        case manualAssociatedDomains
        case linkedServices
        case attachments
        case isFavorite
    }
    
    public let id: Identifier
    @Linked
    public var category: CredentialCategory?
    public var anonId: String
    public let metadata: RecordMetadata
    
    public var login: String
    public var secondaryLogin: String
    public var title: String
    public var password: String
    public var email: String
    @JSONEncoded
    public var attachments: Set<Attachment>?
    
        private(set) var legacyOTPSecret: String
        private(set) var rawOTPURL: URL?
    public var otpURL: URL? {
        get {
            if !legacyOTPSecret.isEmpty {
                let loginToUse = !email.isEmpty ? email : login
                return URLComponents(otpIssuer: title, email: loginToUse, secret: legacyOTPSecret).url
            } else {
                return rawOTPURL
            }
        }
        set {
            rawOTPURL = newValue
            legacyOTPSecret = ""
        }
    }
    
    public var url: PersonalDataURL?
    public var userSelectedUrl: PersonalDataURL?
    public var useFixedUrl: Bool
    public var subdomainOnly: Bool
        public var trustedUrlGroup: [TrustedURL]
    @JSONEncoded
    public var manualAssociatedDomains: Set<String>
    @JSONEncoded
    public var linkedServices: LinkedServices
    public var autoLogin: Bool
    public var numberOfUse: Int
    public var lastUseDate: Date?

    public var note: String
        public var passwordModificationDate: Date?
    public var creationDatetime: Date?
    public var userModificationDatetime: Date?

    public var disabledForPasswordAnalysis: Bool
    public var spaceId: String?
    public let localeFormat: String?
    public var isProtected: Bool
    public var isFavorite: Bool
    
            public init() {
        id = Identifier()
        anonId = UUID().uuidString
        url = nil
        metadata = RecordMetadata(id: .temporary, contentType: .credential)
        userSelectedUrl = nil
        useFixedUrl = false
        trustedUrlGroup = []
        login = ""
        secondaryLogin = ""
        title = ""
        password = ""
        email = ""
        note = ""
        autoLogin = true
        creationDatetime = Date()
        userModificationDatetime = nil
        legacyOTPSecret = ""
        rawOTPURL = nil
        disabledForPasswordAnalysis = false
        spaceId = nil
        localeFormat = "UNIVERSAL"
        subdomainOnly = false
        isProtected = false
        isFavorite = false
        _manualAssociatedDomains = .init([])
        _linkedServices = .init(LinkedServices.defaultValue)
        numberOfUse = 0
        _attachments = .init(nil)
    }
    
    public init(id: Identifier = .init(),
                category: Linked<CredentialCategory> = .init(nil),
                anonId: String = UUID().uuidString,
                login: String,
                secondaryLogin: String = "",
                title: String = "",
                password: String,
                email: String = "",
                otpURL: URL? = nil,
                url: String? = nil,
                userSelectedUrl: PersonalDataURL? = nil,
                useFixedUrl: Bool = false,
                subdomainOnly: Bool = false,
                trustedUrlGroup: [TrustedURL] = [],
                linkedServices: LinkedServices = LinkedServices.defaultValue,
                autoLogin: Bool = true,
                numberOfUse: Int = 0,
                lastUseDate: Date? = nil,
                note: String = "",
                passwordModificationDate: Date? = nil,
                creationDatetime: Date? = .init(),
                userModificationDatetime: Date? = .init(),
                disabledForPasswordAnalysis: Bool = false,
                spaceId: String? = nil,
                localeFormat: String? = "UNIVERSAL",
                isProtected: Bool = false,
                isShared: Bool = false,
                isFavorite: Bool = false,
                sharingPermission: SharingPermission? = nil) {
        self.id = id
        self._category = category
        self.anonId = anonId
        metadata = RecordMetadata(id: .temporary, contentType: .credential, isShared: isShared, sharingPermission: sharingPermission)
        self.login = login
        self.secondaryLogin = secondaryLogin
        self.title = title
        self.password = password
        self.email = email
        self.rawOTPURL = otpURL
        self.legacyOTPSecret = ""
        self.url = url.map { PersonalDataURL(rawValue: $0, domain: nil, host: nil) }
        self.userSelectedUrl = userSelectedUrl
        self.useFixedUrl = useFixedUrl
        self.subdomainOnly = subdomainOnly
        self.trustedUrlGroup = trustedUrlGroup
        self.autoLogin = autoLogin
        self.numberOfUse = numberOfUse
        self.lastUseDate = lastUseDate
        self.note = note
        self.passwordModificationDate = passwordModificationDate
        self.creationDatetime = creationDatetime
        self.userModificationDatetime = userModificationDatetime
        self.disabledForPasswordAnalysis = disabledForPasswordAnalysis
        self.spaceId = spaceId
        self.localeFormat = localeFormat
        self.isProtected = isProtected
        self.numberOfUse = 0
        self.isFavorite = isFavorite
        _linkedServices = .init(linkedServices)
        _manualAssociatedDomains = .init([])
        _attachments = .init(nil)
    }
}

extension Credential {
    
    public mutating func prepareForSaving() {
                let mail = DashTypes.Email(login)
        if mail.isValid && email.isEmptyOrWhitespaces() {
            email = login
            login = ""
        } else if !(DashTypes.Email(email)).isValid && login.isEmptyOrWhitespaces() {
            login = email
            email = ""
        }
        
                let urlValue = url?.rawValue ?? ""
        if let url = URL(string: urlValue), url.scheme == nil {
            self.url = PersonalDataURL(rawValue: "_" + urlValue)
        }
        
        let userSelectedUrlValue = userSelectedUrl?.rawValue ?? ""
        if let userSelectedUrl = URL(string: userSelectedUrlValue), userSelectedUrl.scheme == nil {
            self.userSelectedUrl = PersonalDataURL(rawValue: "_" + userSelectedUrlValue)
        }
    
        self.useFixedUrl = (userSelectedUrl != nil)
        
                if title.isEmpty, let displayDomain = url?.displayDomain {
            title = displayDomain
        }
        
                if legacyOTPSecret.isEmpty, let secret = otpURL?.standardOTPSecret() {
            legacyOTPSecret = secret
        }
    }
}

extension Credential: Searchable {
        private var searchableDomain: String {
        let linkedDomains = url?.domain?.linkedDomains ?? []
        let linkedServices = linkedServices.associatedDomains.map { $0.domain }
        return (linkedDomains + linkedServices).joined(separator: " ")
    }
    
    public var searchableKeyPaths: [KeyPath<Credential, String>] {
        [
            \Credential.title,
            \Credential.login,
            \Credential.secondaryLogin,
            \Credential.email,
            \Credential.searchableDomain,
            \Credential.note
        ]
    }
}

extension Credential: Displayable {
    public var displayTitle: String {
        if !title.isEmpty {
            let charactersToTrim = CharacterSet(arrayLiteral: "\"")
            return title.trimmingCharacters(in: charactersToTrim)
        } else {
            return url?.displayDomain ?? ""
        }
    }
    
    public var displaySubtitle: String? {
        
        if !login.isEmpty {
            return login
        }
        
        if !email.isEmpty {
            return email
        }
        
        if let url = self.url {
            return URL(string: url.rawValue)?.host
        }
        
        return nil
    }
    
    public var displayLogin: String {
        get {
            if !login.isEmpty {
                return login
            } else if !secondaryLogin.isEmpty {
                return secondaryLogin
            } else {
                return email
            }
        }
        set {
            login = newValue
        }
    }
    
    public var editableURL: String {
        get {
            return url?.rawValue ?? ""
        }
        set {
            url = PersonalDataURL(rawValue: newValue)
        }
    }
}

fileprivate extension URL {
        func standardOTPSecret() -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryDictionary(),
              let secret = queryItems["secret"],
              !secret.isEmpty,
              let type = host,
              type == "totp" else {
                  return nil
              }
        let period = queryItems["period"] ?? "30"
        let digits = queryItems["digits"] ?? "6"
        let algorithm = queryItems["algorithm"] ?? "sha1"
        
        guard TimeInterval(period) == 30,
              Int(digits) == 6,
              algorithm.lowercased() == "sha1" else {
                  return nil
              }
        
        return secret
    }
}

fileprivate extension URLComponents {
    func queryDictionary() -> [String: String]? {
        guard let queryItems = queryItems else {
            return nil
        }
        var query: [String: String] = [:]
        for queryItem in queryItems {
            query[queryItem.name] = queryItem.value
        }
        return query
    }
    
    init(otpIssuer issuer: String, email: String, secret: String) {
        self = .init()
        self.scheme = "otpauth"
        self.host = "totp"
        self.path = "/" + issuer + ":" + email
        self.queryItems = [URLQueryItem(name: "secret", value: secret)]
    }
}

private extension Credential {
    var sortableId: String {
        if !login.isEmpty {
            return login
        } else if !secondaryLogin.isEmpty {
            return secondaryLogin
        } else {
            return email
        }
    }
}

extension Collection where Element == Credential {
        public func sortedByLastUsage() -> [Element] {
        self.sorted { credentialL, credentialR in
            switch (credentialL.metadata.lastLocalUseDate, credentialR.metadata.lastLocalUseDate) {
                case (nil, nil):
                                        return credentialL.sortableId.lowercased() < credentialR.sortableId.lowercased()
                case (.some, nil):
                    return true
                case (nil, .some):
                    return false
                case let (.some(firstDate), .some(secondDate)):
                    return firstDate.compare(secondDate) == .orderedDescending
            }
        }
    }
}
