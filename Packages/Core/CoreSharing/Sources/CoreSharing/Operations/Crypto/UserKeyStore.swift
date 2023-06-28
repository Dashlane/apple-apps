import Foundation
import CyrilKit

@SharingActor
class UserKeyStore {
    enum UserKeyError: Error {
        case notDefinedYet
    }
    private var keyPair: AsymmetricKeyPair?

    var needsKey: Bool {
        return keyPair == nil
    }

    func update(_ keyPair: AsymmetricKeyPair) {
        self.keyPair = keyPair
    }

    func get() throws -> AsymmetricKeyPair {
        guard let pair = keyPair else {
            throw UserKeyError.notDefinedYet
        }

        return pair
    }
}
