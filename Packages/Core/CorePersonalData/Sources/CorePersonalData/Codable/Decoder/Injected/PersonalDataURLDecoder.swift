import Foundation

public protocol PersonalDataURLDecoder {
        func decodeURL(_ url: String) throws -> PersonalDataURL
}

public struct PersonalDataURLDecoderMock: PersonalDataURLDecoder {
    let personalDataURL: PersonalDataURL?

    public func decodeURL(_ url: String) throws -> PersonalDataURL {
        personalDataURL ?? PersonalDataURL(rawValue: url)
    }
}

extension PersonalDataURLDecoder where Self == PersonalDataURLDecoderMock {
    public static func mock(url: PersonalDataURL? = nil) -> PersonalDataURLDecoderMock {
        return PersonalDataURLDecoderMock(personalDataURL: url)
    }
}
