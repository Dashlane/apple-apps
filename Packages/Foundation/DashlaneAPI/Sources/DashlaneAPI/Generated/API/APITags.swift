import Foundation

extension AppAPIClient {

  public struct Abtesting: Sendable {
    let api: AppAPIClient
  }
  public var abtesting: Abtesting {
    Abtesting(api: self)
  }

  public struct Account: Sendable {
    let api: AppAPIClient
  }
  public var account: Account {
    Account(api: self)
  }

  public struct Accountrecovery: Sendable {
    let api: AppAPIClient
  }
  public var accountrecovery: Accountrecovery {
    Accountrecovery(api: self)
  }

  public struct Analytics: Sendable {
    let api: AppAPIClient
  }
  public var analytics: Analytics {
    Analytics(api: self)
  }

  public struct Authentication: Sendable {
    let api: AppAPIClient
  }
  public var authentication: Authentication {
    Authentication(api: self)
  }

  public struct AuthenticationQA: Sendable {
    let api: AppAPIClient
  }
  public var authenticationQA: AuthenticationQA {
    AuthenticationQA(api: self)
  }

  public struct Authenticator: Sendable {
    let api: AppAPIClient
  }
  public var authenticator: Authenticator {
    Authenticator(api: self)
  }

  public struct Breaches: Sendable {
    let api: AppAPIClient
  }
  public var breaches: Breaches {
    Breaches(api: self)
  }

  public struct Country: Sendable {
    let api: AppAPIClient
  }
  public var country: Country {
    Country(api: self)
  }

  public struct Darkwebmonitoring: Sendable {
    let api: AppAPIClient
  }
  public var darkwebmonitoring: Darkwebmonitoring {
    Darkwebmonitoring(api: self)
  }

  public struct DarkwebmonitoringQA: Sendable {
    let api: AppAPIClient
  }
  public var darkwebmonitoringQA: DarkwebmonitoringQA {
    DarkwebmonitoringQA(api: self)
  }

  public struct Features: Sendable {
    let api: AppAPIClient
  }
  public var features: Features {
    Features(api: self)
  }

  public struct File: Sendable {
    let api: AppAPIClient
  }
  public var file: File {
    File(api: self)
  }

  public struct Iconcrawler: Sendable {
    let api: AppAPIClient
  }
  public var iconcrawler: Iconcrawler {
    Iconcrawler(api: self)
  }

  public struct Invitation: Sendable {
    let api: AppAPIClient
  }
  public var invitation: Invitation {
    Invitation(api: self)
  }

  public struct Killswitch: Sendable {
    let api: AppAPIClient
  }
  public var killswitch: Killswitch {
    Killswitch(api: self)
  }

  public struct Mpless: Sendable {
    let api: AppAPIClient
  }
  public var mpless: Mpless {
    Mpless(api: self)
  }

  public struct Platforms: Sendable {
    let api: AppAPIClient
  }
  public var platforms: Platforms {
    Platforms(api: self)
  }

  public struct SecretTransfer: Sendable {
    let api: AppAPIClient
  }
  public var secretTransfer: SecretTransfer {
    SecretTransfer(api: self)
  }

  public struct Teams: Sendable {
    let api: AppAPIClient
  }
  public var teams: Teams {
    Teams(api: self)
  }
}

extension UnsignedAPIClient {

  public struct Monitoring: Sendable {
    let api: UnsignedAPIClient
  }
  public var monitoring: Monitoring {
    Monitoring(api: self)
  }

  public struct Time: Sendable {
    let api: UnsignedAPIClient
  }
  public var time: Time {
    Time(api: self)
  }
}

extension UserDeviceAPIClient {

  public struct Abtesting: Sendable {
    let api: UserDeviceAPIClient
  }
  public var abtesting: Abtesting {
    Abtesting(api: self)
  }

  public struct Account: Sendable {
    let api: UserDeviceAPIClient
  }
  public var account: Account {
    Account(api: self)
  }

  public struct Accountrecovery: Sendable {
    let api: UserDeviceAPIClient
  }
  public var accountrecovery: Accountrecovery {
    Accountrecovery(api: self)
  }

  public struct Authentication: Sendable {
    let api: UserDeviceAPIClient
  }
  public var authentication: Authentication {
    Authentication(api: self)
  }

  public struct Authenticator: Sendable {
    let api: UserDeviceAPIClient
  }
  public var authenticator: Authenticator {
    Authenticator(api: self)
  }

  public struct Breaches: Sendable {
    let api: UserDeviceAPIClient
  }
  public var breaches: Breaches {
    Breaches(api: self)
  }

  public struct Darkwebmonitoring: Sendable {
    let api: UserDeviceAPIClient
  }
  public var darkwebmonitoring: Darkwebmonitoring {
    Darkwebmonitoring(api: self)
  }

  public struct Devices: Sendable {
    let api: UserDeviceAPIClient
  }
  public var devices: Devices {
    Devices(api: self)
  }

  public struct Features: Sendable {
    let api: UserDeviceAPIClient
  }
  public var features: Features {
    Features(api: self)
  }

  public struct File: Sendable {
    let api: UserDeviceAPIClient
  }
  public var file: File {
    File(api: self)
  }

  public struct Icons: Sendable {
    let api: UserDeviceAPIClient
  }
  public var icons: Icons {
    Icons(api: self)
  }

  public struct Invitation: Sendable {
    let api: UserDeviceAPIClient
  }
  public var invitation: Invitation {
    Invitation(api: self)
  }

  public struct Mpless: Sendable {
    let api: UserDeviceAPIClient
  }
  public var mpless: Mpless {
    Mpless(api: self)
  }

  public struct Pairing: Sendable {
    let api: UserDeviceAPIClient
  }
  public var pairing: Pairing {
    Pairing(api: self)
  }

  public struct Payments: Sendable {
    let api: UserDeviceAPIClient
  }
  public var payments: Payments {
    Payments(api: self)
  }

  public struct Premium: Sendable {
    let api: UserDeviceAPIClient
  }
  public var premium: Premium {
    Premium(api: self)
  }

  public struct SecretTransfer: Sendable {
    let api: UserDeviceAPIClient
  }
  public var secretTransfer: SecretTransfer {
    SecretTransfer(api: self)
  }

  public struct Securefile: Sendable {
    let api: UserDeviceAPIClient
  }
  public var securefile: Securefile {
    Securefile(api: self)
  }

  public struct SharingUserdevice: Sendable {
    let api: UserDeviceAPIClient
  }
  public var sharingUserdevice: SharingUserdevice {
    SharingUserdevice(api: self)
  }

  public struct Sync: Sendable {
    let api: UserDeviceAPIClient
  }
  public var sync: Sync {
    Sync(api: self)
  }

  public struct Teams: Sendable {
    let api: UserDeviceAPIClient
  }
  public var teams: Teams {
    Teams(api: self)
  }

  public struct User: Sendable {
    let api: UserDeviceAPIClient
  }
  public var user: User {
    User(api: self)
  }

  public struct Useractivity: Sendable {
    let api: UserDeviceAPIClient
  }
  public var useractivity: Useractivity {
    Useractivity(api: self)
  }

  public struct Vpn: Sendable {
    let api: UserDeviceAPIClient
  }
  public var vpn: Vpn {
    Vpn(api: self)
  }
}
