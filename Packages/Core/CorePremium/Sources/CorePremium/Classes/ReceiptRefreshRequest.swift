import Foundation
import StoreKit

enum ReceiptRefreshRequestResult {
    case success
    case error(Error)
}

final class ReceiptRefreshRequest: SKReceiptRefreshRequest {
    let completion: (ReceiptRefreshRequestResult) -> Void
    init(completion: @escaping (ReceiptRefreshRequestResult) -> Void) {
        self.completion = completion
        super.init()
        self.delegate = self
    }
}

extension ReceiptRefreshRequest: SKRequestDelegate {
    public func requestDidFinish(_ request: SKRequest) {
        self.completion(.success)
    }
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        self.completion(.error(error))
    }
}
