import Foundation

extension Data {
  #if DEBUG
    static var testIV: Data?
  #endif

  static func makeIV(size: Int) -> Data {
    #if DEBUG
      if let testIV, testIV.count == size {
        return testIV
      }
    #endif
    return Data.random(ofSize: size)
  }
}
