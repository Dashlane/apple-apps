import Foundation
import DashlaneAPI
import SwiftTreats
import DashTypes

extension AppAPIClient {
    public init(configuration: APIConfiguration) {
        let appCredentials = DashlaneAPI.AppCredentials(accessKey: ApplicationSecrets.Server.apiKey,
                                                        secretKey: ApplicationSecrets.Server.apiSecret)

        self.init(configuration: configuration, appCredentials: appCredentials)
    }

    public init(platform: Platform = .passwordManager, environment: APIConfiguration.Environment = .default) throws {
        try self.init(configuration: APIConfiguration(info: .init(platform: platform), environment: environment))
    }
}

extension APIConfiguration.Info {
    public init(platform: Platform = .passwordManager, appVersion: String = Application.version()) {
        self.init(platform: platform.rawValue, appVersion: appVersion, osVersion: Device.systemVersion, partnerId: ApplicationSecrets.Server.partnerId)
    }
}
