import Foundation

public struct FailableDecodable<Base: Codable>: Codable {

	public let base: Base?

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self.base = try? container.decode(Base.self)
	}
}
