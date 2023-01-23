import Foundation

extension Encodable {
    var jsonRepresentation: String {
        guard let encoded = try? JSONEncoder().encode(self) else { return "" }
        return String(data: encoded, encoding: .utf8) ?? ""
    }
}
