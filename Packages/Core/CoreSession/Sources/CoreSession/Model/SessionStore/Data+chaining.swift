import Foundation
import DashTypes

extension Data {
    func decode<T: Codable>(using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}

extension Encodable {
    func encode(using encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
}
