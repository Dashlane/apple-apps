import Foundation
import CorePersonalData

extension VaultItemsService {
    func configurePrefilledCredentials(using urlDecoder: PersonalDataURLDecoderProtocol) {
        let prefilledCredentials = PrefilledCredentials.all()
        self.prefilledCredentials = prefilledCredentials.map {
            Credential(
                service: $0,
                email: login.email,
                url: try? urlDecoder.decodeURL($0.url))
        }
    }
}
