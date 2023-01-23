import Foundation

public struct DashlaneResponse<T: Decodable>: Decodable {

		public let code: Int

		public let content: T

		public let message: String?
}

struct Message: Decodable {
    let message: String
}
