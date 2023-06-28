import Foundation

struct Response<T: Codable>: Codable {

        let code: Int

        let content: T

        let message: String?
}
