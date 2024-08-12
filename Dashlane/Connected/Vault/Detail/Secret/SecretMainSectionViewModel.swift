import CorePersonalData
import Foundation
import VaultKit

public class SecretMainSectionModel: DetailViewModelProtocol {
  public let service: DetailService<Secret>

  public init(
    service: DetailService<Secret>
  ) {
    self.service = service
  }
}

extension SecretMainSectionModel {
  static func mock(
    service: DetailService<Secret>
  ) -> SecretMainSectionModel {
    .init(
      service: service
    )
  }
}
