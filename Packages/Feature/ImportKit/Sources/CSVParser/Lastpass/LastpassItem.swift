import Foundation

public struct LastpassItem: Equatable {

        public let name: String

        public let url: String

                public let username: String

        public let password: String

        public let extra: String

        public let otp: String?

    init(
        name: String,
        url: String,
        username: String,
        password: String,
        extra: String,
        otp: String
    ) {
        self.name = name
        self.url = url
        self.username = username
        self.password = password
        self.extra = extra
        self.otp = otp
    }

    init?(csvContent: [String: String]) {
        guard let name = csvContent[LastpassHeader.name.rawValue],
              let url = csvContent[LastpassHeader.url.rawValue],
              let username = csvContent[LastpassHeader.username.rawValue],
              let password = csvContent[LastpassHeader.password.rawValue],
              let extra = csvContent[LastpassHeader.extra.rawValue],
              let otp = csvContent[LastpassHeader.totp.rawValue]
        else { return nil }

        self.init(
            name: name,
            url: url,
            username: username,
            password: password,
            extra: extra,
            otp: otp)
    }

}
