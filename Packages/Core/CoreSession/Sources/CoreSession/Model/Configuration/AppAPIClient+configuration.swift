import Foundation
import DashlaneAPI

extension AppAPIClient {
    public func makeUserClient(sessionConfiguration: SessionConfiguration) -> UserDeviceAPIClient {
        let signedAuthentication = sessionConfiguration.keys.serverAuthentication.signedAuthentication
        
        return self.makeUserClient(credentials: UserCredentials(login: sessionConfiguration.login.email,
                                                                deviceAccessKey: signedAuthentication.deviceAccessKey,
                                                                deviceSecretKey: signedAuthentication.deviceSecretKey))
    }
}

