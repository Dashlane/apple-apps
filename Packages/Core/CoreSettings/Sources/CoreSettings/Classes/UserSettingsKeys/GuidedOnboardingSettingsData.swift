import Foundation

@objc(GuidedOnboardingSettingsData)
public class GuidedOnboardingSettingsData: NSObject, Codable, NSCoding, DataConvertible {
    public let questionId: Int
    public let answerId: Int?

    enum CodingKeys: String, CodingKey {
        case questionId
        case answerId
    }

    public init(questionId: Int, answerId: Int?) {
        self.questionId = questionId
        self.answerId = answerId
    }

    public var binaryData: Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            fatalError("Data could not be decoded")
        }
    }

    required public init?(binaryData: Data) {
        guard let decodedData = try? JSONDecoder().decode(GuidedOnboardingSettingsData.self, from: binaryData) else {
            return nil
        }
        self.questionId = decodedData.questionId
        self.answerId = decodedData.answerId
    }

    public func encode(with coder: NSCoder) {
        coder.encode(questionId, forKey: CodingKeys.questionId.rawValue)
        if let answerId = answerId {
            coder.encode(NSNumber(integerLiteral: answerId), forKey: CodingKeys.answerId.rawValue)
        }
    }

    required public init?(coder: NSCoder) {
        questionId = coder.decodeInteger(forKey: CodingKeys.questionId.rawValue)
        if let answerId = coder.decodeObject(forKey: CodingKeys.answerId.rawValue) as? NSNumber {
            self.answerId = answerId.intValue
        } else {
            self.answerId = nil
        }
    }
}
