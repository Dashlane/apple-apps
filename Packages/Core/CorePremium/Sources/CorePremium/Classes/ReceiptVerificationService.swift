import Foundation
import StoreKit
import DashTypes

public struct VerificationResult: Decodable {
    public let success: Bool
}

public struct VerificationError: Decodable {
    public enum ErrorType: String, Decodable {
        case emptyReceipt = "no_receipt_item"
        case generic
    }

    public let refreshReceipt: Bool
    public let type: ErrorType

    private enum CodingKeys: String, CodingKey {
        case refreshReceipt
        case type = "error"
    }

    private enum ErrorKeys: CodingKey {
        case content
    }

    private enum ContentsKeys: CodingKey {
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            let errorContainer = try container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .type)
            let contentsContainer = try errorContainer.nestedContainer(keyedBy: ContentsKeys.self, forKey: .content)
            type = try contentsContainer.decode(ErrorType.self, forKey: .message)
        } catch {
            type = .generic
        }

        refreshReceipt = (try? container.decode(Bool.self, forKey: .refreshReceipt)) ?? false
    }
}

public enum VerificationFailure: Error, Equatable {
    public enum Reason {
        case emptyReceipt
    }

    case unknown
    case receiptRefreshRequired(reason: Reason? = nil)


}

public final class ReceiptVerificationService {
    
    private enum Endpoint: String {
        case status = "/3/premium/verifyReceipt"
    }
    
    private enum Key: String {
        case receipt
        case transactionIdentifier
        case origin
        case plan
        case regionCode = "billingCountry"
        case price = "amount"
        case currencyCode = "currency"
    }
    
    private struct Constants {
                static let origin = "ios"
    }
    
    private let webservice: LegacyWebService

        public init(webservice: LegacyWebService) {
        self.webservice = webservice
    }
    

    
    public func verify(_ receipt: Data,
                                          transactionId: String? = "",
                                          planName: String? = "",
                                          regionCode: String? = nil,
                                          price: Double? = 0,
                                          currencyCode: String? = "",
                                          completion handler: @escaping (Result<VerificationResult, Error>) -> Void) {
        var parameters: [String: Encodable] = [Key.receipt.rawValue: receipt.base64EncodedString(),
                                               Key.transactionIdentifier.rawValue: transactionId ?? "",
                                               Key.origin.rawValue: Constants.origin,
                                               Key.plan.rawValue: planName ?? "",
                                               Key.price.rawValue: price ?? 0,
                                               Key.currencyCode.rawValue: currencyCode ?? ""]
        if let regionCode = regionCode {
            parameters[Key.regionCode.rawValue] = regionCode
        }
        let resource = Resource.init(endpoint: Endpoint.status.rawValue,
                                     method: .post,
                                     params: parameters,
                                     contentFormat: .queryString,
                                     needsAuthentication: true,
                                     parser: ReceiptVerificationServiceParser())
        resource.load(on: webservice, completion: handler)
    }
}

struct ReceiptVerificationServiceParser: ResponseParserProtocol {

    func parse(data: Data) throws -> VerificationResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        do {
            let result = try decoder.decode(VerificationResult.self, from: data)
            return result
        } catch {
            let result: VerificationError
            do {
                result = try decoder.decode(VerificationError.self, from: data)
            } catch {
                throw VerificationFailure.unknown
            }

            if result.refreshReceipt {
                throw VerificationFailure.receiptRefreshRequired(reason: result.type == .emptyReceipt ? .emptyReceipt : nil)
            } else {
                throw VerificationFailure.unknown
            }
        }
    }
}
