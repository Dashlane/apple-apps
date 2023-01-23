import Foundation
import DashTypes

public struct SignatureResponse: Decodable {
    
        public let keyIdentifier: String
    
        public let nonce: String
    
        public let signature: String
    
        public let timestamp: String
}

public struct SignatureService {
    
                                        public static func getSignature(appBundleID: String,
                             productIdentifier: String,
                             offerIdentifier: String,
                             applicationUsername: String,
                             authenticatedAPIClient dashlaneAPI: DeprecatedCustomAPIClient,
                             completion: @escaping (Result<SignatureResponse, Error>) -> Void) {
        
        let endpoint = "/v1/premium/GetAppleSubscriptionOfferSignature"
        
        struct Params: Encodable {
            let appBundleID: String
            let productIdentifier: String
            let offerIdentifier: String
            let applicationUsername: String
        }
        
        let params = Params(appBundleID: appBundleID,
                            productIdentifier: productIdentifier,
                            offerIdentifier: offerIdentifier,
                            applicationUsername: applicationUsername)
        
        dashlaneAPI.sendRequest(to: endpoint,
                               using: HTTPMethod.post,
                               input: params,
                               completion: completion)
    }
}
