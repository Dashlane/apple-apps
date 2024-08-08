import CoreRegion
import DashTypes
import DashlaneAPI
import Foundation
import VaultKit

public typealias UserCountryInfo = AppAPIClient.Country.GetIpCountry.Response

struct UserCountryProvider {
  let defaultUserCountry: UserCountryInfo
  let appAPIClient: AppAPIClient

  init(regionInformationService: RegionInformationService, appAPIClient: AppAPIClient) {
    let country = Locale.current.region?.identifier ?? "US"
    let isEu = regionInformationService.europeanUnionInfo.contains(countryCode: country)

    defaultUserCountry = UserCountryInfo(country: country, isEu: isEu, isUS: country == "US")
    self.appAPIClient = appAPIClient
  }

  fileprivate init(defaultUserCountry: UserCountryInfo, appAPIClient: AppAPIClient) {
    self.defaultUserCountry = defaultUserCountry
    self.appAPIClient = appAPIClient
  }

  var userCountry: UserCountryInfo {
    get async {
      do {
        let userCountry = try await appAPIClient.country.getIpCountry(timeout: 10)
        return userCountry
      } catch {
        return defaultUserCountry
      }
    }
  }
}

extension UserCountryProvider {
  static func mock(userCountryInfos: UserCountryInfo) -> UserCountryProvider {
    UserCountryProvider(defaultUserCountry: userCountryInfos, appAPIClient: .fake)
  }
}

extension UserCountryInfo {
  static var france: UserCountryInfo {
    .init(country: "FR", isEu: true, isUS: false)
  }

  static var usa: UserCountryInfo {
    .init(country: "US", isEu: false, isUS: true)
  }
}

extension AppServicesContainer {
  var userCountryProvider: UserCountryProvider {
    return .init(regionInformationService: regionInformationService, appAPIClient: appAPIClient)
  }
}
