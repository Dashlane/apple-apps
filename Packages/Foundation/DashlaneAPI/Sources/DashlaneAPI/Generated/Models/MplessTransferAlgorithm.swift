import Foundation

public enum MplessTransferAlgorithm: String, Codable, Equatable, CaseIterable {
    case directHKDFSHA256 = "direct+HKDF-SHA-256"
}
