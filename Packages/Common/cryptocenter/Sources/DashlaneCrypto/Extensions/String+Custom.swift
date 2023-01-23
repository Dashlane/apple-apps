import Foundation

extension String {

    init?(byteArray: [UInt8]) {
        guard let str = String(data: Data( byteArray), encoding: .utf8) else {
            return nil
        }
        self = str
    }

    func pemFormat(withHeader header: String, footer: String) -> String {
        var result: [String] = [header]
        let characters = Array(self)
        let lineSize = 64
        stride(from: 0, to: characters.count, by: lineSize).forEach {
            result.append(String(characters[$0..<min($0+lineSize, characters.count)]))
        }
        result.append(footer)
        return result.joined(separator: "\n")
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
