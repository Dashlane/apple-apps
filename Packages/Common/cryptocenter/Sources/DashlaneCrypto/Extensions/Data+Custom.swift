import Foundation

extension Data {

    init?(key: SecKey) {
        var error: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) else {
            return nil
        }
        if let error = error {
            error.release()
            return nil
        }
        self = keyData as Data
    }

}
