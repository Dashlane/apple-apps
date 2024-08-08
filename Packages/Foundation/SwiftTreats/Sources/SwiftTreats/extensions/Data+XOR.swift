import Foundation

extension Data {
  public static func ^ (left: Data, right: Data) -> Data {
    if left.count != right.count {
      NSLog("Warning! XOR operands are not equal. left = \(left), right = \(right)")
    }

    var result: Data = Data()
    var smaller: Data
    var bigger: Data
    if left.count <= right.count {
      smaller = left
      bigger = right
    } else {
      smaller = right
      bigger = left
    }

    let bs: [UInt8] = Array(smaller)
    let bb: [UInt8] = Array(bigger)
    var br = [UInt8]()
    for i in 0..<bs.count {
      br.append(bs[i] ^ bb[i])
    }
    for j in bs.count..<bb.count {
      br.append(bb[j])
    }
    result = Data(br)
    return result
  }
}
