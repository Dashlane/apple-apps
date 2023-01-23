import Foundation

extension UserEvent {

public struct `AuthenticatorDownloadPasswordManager`: Encodable, UserEventProtocol {
public static let isPriority = false
public init() {

}
public let name = "authenticator_download_password_manager"
}
}
