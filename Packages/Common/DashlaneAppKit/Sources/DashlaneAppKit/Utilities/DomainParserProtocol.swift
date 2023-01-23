import Foundation
import DomainParser

public protocol DomainParserProtocol {
    func parse(host: String) -> ParsedHost?
}

extension DomainParser: DomainParserProtocol { }

public struct DomainParserMock: DomainParserProtocol {
    public init(){}
    public func parse(host: String) -> ParsedHost? {
        return nil
    }
}
