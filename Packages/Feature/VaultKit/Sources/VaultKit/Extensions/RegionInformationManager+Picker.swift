import CorePersonalData
import CoreRegion
import Foundation

extension RegionInformationManager where T == GeographicalState {

  public func states(forCountryCode code: String?) -> [StateCodeNamePair] {
    guard let code = code else {
      return []
    }

    let items = self.items(forCode: code).map {
      StateCodeNamePair(
        components: RegionCodeComponentsInfo(
          countryCode: code,
          subcode: $0.code),
        name: $0.localizedString)
    }
    return items
  }
}

extension RegionInformationManager where T == Bank {

  public func banks(forCountryCode code: String?) -> [BankCodeNamePair] {
    guard let code = code else {
      return []
    }
    let items = self.items(forCode: code).map { bank in
      BankCodeNamePair(code: "\(code)-\(bank.code)", name: bank.localizedString)
    }.sorted { item, _ in
      item.code == "\(code)-NO_TYPE"
    }
    return items
  }

}
