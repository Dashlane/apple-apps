import Foundation

public enum COSEAlgorithmIdentifier: Int, RawRepresentable, Codable, CaseIterable {
  case es256 = -7
  case es384 = -35
  case es512 = -36
}
