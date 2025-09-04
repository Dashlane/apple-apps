import Foundation

extension Definition {

  public struct `OtpSpecifications`: Encodable, Sendable {
    public init(
      `durationOtpValidity`: Int? = nil,
      `encryptionAlgorithm`: Definition.EncryptionAlgorithm? = nil,
      `otpCodeSize`: Int? = nil, `otpIncrementCount`: Int? = nil, `otpType`: Definition.OtpType
    ) {
      self.durationOtpValidity = durationOtpValidity
      self.encryptionAlgorithm = encryptionAlgorithm
      self.otpCodeSize = otpCodeSize
      self.otpIncrementCount = otpIncrementCount
      self.otpType = otpType
    }
    public let durationOtpValidity: Int?
    public let encryptionAlgorithm: Definition.EncryptionAlgorithm?
    public let otpCodeSize: Int?
    public let otpIncrementCount: Int?
    public let otpType: Definition.OtpType
  }
}
