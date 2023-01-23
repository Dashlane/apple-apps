import Foundation

extension UserEvent {

public struct `DownloadVpnClient`: Encodable, UserEventProtocol {
public static let isPriority = false
public init() {

}
public let name = "download_vpn_client"
}
}
