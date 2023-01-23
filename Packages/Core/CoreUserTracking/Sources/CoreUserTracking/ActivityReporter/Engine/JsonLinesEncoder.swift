import Foundation

struct JSONLinesEncoder {
    enum Error: Swift.Error {
        case impossibleToConvertToUTF8Data
    }
    
    init() {}
    
    func encode(_ jsonElements: [Data]) throws -> Data {
        let data = jsonElements.compactMap { String(data: $0, encoding: .utf8) }
            .joined(separator: "\n").data(using: .utf8)
        guard let encodedData = data else {
            throw Error.impossibleToConvertToUTF8Data
        }
        return encodedData
    }
}
