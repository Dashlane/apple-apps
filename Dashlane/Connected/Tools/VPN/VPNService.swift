import CorePersonalData
import CorePremium
import DashTypes
import DashlaneAPI
import Foundation
import VaultKit

public protocol VPNServiceProtocol {
  var isAvailable: Bool { get }
  var capabilityIsEnabled: Bool { get }
  var reasonOfUnavailability: CorePremium.Status.Capabilities.Info.Reason? { get }
  func activateEmail(_ email: String) async throws
}

class VPNService: VPNServiceProtocol {
  private let capabilityService: CapabilityServiceProtocol
  private let userDeviceAPIClient: UserDeviceAPIClient
  private let vaultItemDatabase: VaultItemDatabaseProtocol
  private let userSpacesService: UserSpacesService

  static let vpnCredentialTitle = "VPN Hotspot Shield"
  static let vpnCredentialURL = URL(string: "_")!

  #if targetEnvironment(macCatalyst)
    static let vpnExternalAppId = 771_076_721
  #else
    static let vpnExternalAppId = 443_369_807
  #endif

  init(
    capabilityService: CapabilityServiceProtocol,
    userDeviceAPIClient: UserDeviceAPIClient,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    userSpacesService: UserSpacesService
  ) {
    self.capabilityService = capabilityService
    self.userDeviceAPIClient = userDeviceAPIClient
    self.vaultItemDatabase = vaultItemDatabase
    self.userSpacesService = userSpacesService
  }

  public var isAvailable: Bool {
    if case .available = capabilityService.status(of: .secureWiFi) {
      return true
    }
    return false
  }

  public var capabilityIsEnabled: Bool {
    return capabilityService.status(of: .secureWiFi).isAvailable
  }

  public var reasonOfUnavailability: CorePremium.Status.Capabilities.Info.Reason? {
    return capabilityService.capabilities[.secureWiFi]?.info?.reason
  }

  public func activateEmail(_ email: String) async throws {
    let response = try await userDeviceAPIClient.vpn.getCredentials(email: email)
    saveVPNcredential(for: email, andPassword: response.password)
  }
}

extension VPNService {
  fileprivate func saveVPNcredential(for email: String, andPassword password: String) {
    var credential = Credential()
    credential.email = email
    credential.password = password
    credential.title = VPNService.vpnCredentialTitle
    credential.url = PersonalDataURL(rawValue: VPNService.vpnCredentialURL.absoluteString)
    let now = Date()
    credential.userModificationDatetime = now
    credential.passwordModificationDate = now
    credential.spaceId =
      userSpacesService.configuration.defaultSpace(for: credential).personalDataId
    _ = try? vaultItemDatabase.save(credential)
  }
}
