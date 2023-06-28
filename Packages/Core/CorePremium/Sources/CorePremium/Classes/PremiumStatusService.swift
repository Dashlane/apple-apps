import Foundation
import DashTypes

public enum PremiumStatusServiceError: String, Error {
    case incorrectAuthentication = "Incorrect authentification"
}

public final class PremiumStatusService {

    private enum Endpoint: String {
        case status = "/3/premium/status"
    }

    private enum Key: String {
        case key
        case secureFileInfoId
        case autoRenewal
        case teamInformation
        case familyInformation
        case needsAutoRenewalFailed
        case teamSpaces = "spaces"
        case capabilities
        case previousPlan
        case platform
                case checkAdvanced
    }

    private struct Constants {
                static let platform = "iOS"
    }

    private let webservice: LegacyWebService

    public init(webservice: LegacyWebService) {
        self.webservice = webservice
    }

    static public var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    public func getStatus(completion handler: @escaping (Result<(PremiumStatus, Data), Error>) -> Void) {
        let parameters: [String: Codable] = [
            Key.autoRenewal.rawValue: true,
            Key.teamInformation.rawValue: true,
            Key.familyInformation.rawValue: true,
            Key.needsAutoRenewalFailed.rawValue: true,
            Key.teamSpaces.rawValue: true,
            Key.previousPlan.rawValue: true,
            Key.capabilities.rawValue: true,
            Key.platform.rawValue: Constants.platform,
            Key.checkAdvanced.rawValue: true
        ]
        let resource = Resource.init(endpoint: Endpoint.status.rawValue,
                                     method: .post,
                                     params: parameters,
                                     contentFormat: .queryString,
                                     needsAuthentication: true,
                                     parser: GetStatusParser())
        resource.load(on: webservice, completion: handler)
    }
}

struct GetStatusParser: ResponseParserProtocol {
    func parse(data: Data) throws -> (PremiumStatus, Data) {
        let decoder = PremiumStatusService.decoder
        do {
            let status = try decoder.decode(PremiumStatus.self, from: data)
            return (status, data)
        } catch {
            guard let errorMessage = try? decoder.decode(ServerError.self, from: data) else {
                throw error
            }
            guard let serverErrorMessage = PremiumStatusServiceError(rawValue: errorMessage.content) else {
                throw error
            }
            throw serverErrorMessage
        }
    }
}
