import Foundation

public enum CodeFormat {
    case bank
    case state
    case country
}

public protocol CodeDecoder {
        func decodeCode(_ code: String, for: CodeFormat) throws -> String?
}

public struct CodeDecoderMock: CodeDecoder {
    let code: String?

    init(code: String? = nil) {
        self.code = code
    }

    public func decodeCode(_ code: String, for: CodeFormat) throws -> String? {
        return code
    }
}

extension CodeDecoder where Self == CodeDecoderMock {
    public static func mock(code: String? = nil) -> CodeDecoderMock {
        return CodeDecoderMock(code: code)
    }
}
