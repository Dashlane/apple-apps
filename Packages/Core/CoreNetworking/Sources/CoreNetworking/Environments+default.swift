import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

#if DEBUG || NIGHTLY
  extension APIConfiguration.Environment {
    public static var `default`: APIConfiguration.Environment {
      let userDefault = UserDefaults.standard
      guard userDefault.bool(for: .stagingServersEnabled),
        let url = userDefault.sanitizedStringURL(for: .serverURL),
        let url = URL(string: url + "/v1"),
        let cloudflareIdentifier = userDefault.string(for: .cloudflareId),
        let cloudflareSecret = userDefault.string(for: .cloudflareSecret)
      else {
        return .production
      }

      let configuration = StagingInformation(
        apiURL: url,
        cloudflareIdentifier: cloudflareIdentifier,
        cloudflareSecret: cloudflareSecret)

      return .staging(configuration)
    }
  }

  extension NitroSSOConfiguration.Environment {
    public static var `default`: NitroSSOConfiguration.Environment {
      let userDefault = UserDefaults.standard
      guard userDefault.bool(for: .stagingServersEnabled),
        let url = userDefault.sanitizedStringURL(for: .nitroServerURL),
        let url = URL(string: url),
        let cloudflareIdentifier = userDefault.string(for: .nitroCloudflareId),
        let cloudflareSecret = userDefault.string(for: .nitroCloudflareSecret)
      else {
        return .production
      }

      let configuration = StagingInformation(
        apiURL: url,
        cloudflareIdentifier: cloudflareIdentifier,
        cloudflareSecret: cloudflareSecret)

      return .staging(configuration)
    }
  }

  enum CustomConfigurationKey: String {
    case stagingServersEnabled

    case serverURL
    case cloudflareId
    case cloudflareSecret

    case nitroServerURL
    case nitroCloudflareId
    case nitroCloudflareSecret
  }

  extension UserDefaults {
    func string(for key: CustomConfigurationKey) -> String? {
      guard let value = string(forKey: key.rawValue) else {
        return nil
      }

      return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func sanitizedStringURL(for key: CustomConfigurationKey) -> String? {
      guard var value = string(for: key) else {
        return nil
      }

      if value.last == "/" {
        value.removeLast()
      }

      if !value.starts(with: "http") {
        value = "_" + value
      }

      return value
    }

    func bool(for key: CustomConfigurationKey) -> Bool {
      return bool(forKey: key.rawValue)
    }
  }

#else
  extension APIConfiguration.Environment {
    public static var `default`: APIConfiguration.Environment {
      return .production
    }
  }

  extension NitroSSOConfiguration.Environment {
    public static var `default`: NitroSSOConfiguration.Environment {
      return .production
    }
  }

#endif

extension ClientInfo {
  public init(platform: Platform = .passwordManager, appVersion: String = Application.version()) {
    self.init(
      platform: platform.rawValue,
      appVersion: appVersion,
      osVersion: Device.systemVersion,
      partnerId: ApplicationSecrets.Server.partnerId)
  }
}
