import Foundation
import DashTypes
import SwiftTreats

public struct Recover2FAWebService {

    let webService: LegacyWebService
    let login: Login

    public init(webService: LegacyWebService, login: Login) {
        self.webService = webService
        self.login = login
    }

        public func recoverCodes(completion: @escaping CompletionBlock<Void, Recover2FAError>) {
        webService.sendRequest(to: "/6/authentication/otpphonelost",
                               using: .post,
                               params: ["login": login.email],
                               contentFormat: .queryString,
                               needsAuthentication: false,
                               responseParser: Recover2FAResponseParser()) { result in
            switch result {
            case .success:
                completion(.success)
            case let .failure(error):
                guard let recoverError = error as? Recover2FAError else {
                    completion(.failure(.unknown))
                    return
                }
                completion(.failure(recoverError))
            }
        }
    }
}

public enum Recover2FAError: String, Error, Decodable {
    case noValidPhoneNumber = "No valid recovery phone number"
    case unknown
}

private struct Recover2FAResponseParser: ResponseParserProtocol {
    
    struct EmptyResponse: Decodable {
        let code: Int?
    }
    
    func parse(data: Data) throws -> Void {
        let decoder = JSONDecoder()
        if let response = try? decoder.decode(EmptyResponse.self, from: data), response.code == 200 {
            return
        } else if let errorResponse = try? decoder.decode(DashlaneResponse<Recover2FAError>.self, from: data) {
            throw errorResponse.content
        } else {
            throw Recover2FAError.unknown
        }
    }
}
