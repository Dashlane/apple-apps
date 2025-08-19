import CorePersonalData
import VaultKit

public class WifiQRCodeViewModel: DetailViewModelProtocol {
  public let service: DetailService<WiFi>

  public init(
    service: DetailService<WiFi>
  ) {
    self.service = service
  }
}

extension WifiQRCodeViewModel {
  static func mock(
    service: DetailService<WiFi>
  ) -> WifiQRCodeViewModel {
    .init(
      service: service
    )
  }
}
