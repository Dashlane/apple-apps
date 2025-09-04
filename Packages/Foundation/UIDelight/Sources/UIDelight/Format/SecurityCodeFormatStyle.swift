import Foundation
import SwiftUI

public struct SecurityCodeFormatStyle: FormatStyle {
  public func format(_ value: String) -> String {
    guard value.count > 5 else {
      return value
    }

    let index = value.index(value.startIndex, offsetBy: value.count / 2)
    return value[..<index] + " " + value[index...]
  }
}

extension FormatStyle where Self == SecurityCodeFormatStyle {
  public static var securityCode: SecurityCodeFormatStyle { .init() }
}

#Preview {
  VStack {
    Text("123456", format: .securityCode)
    Text("1234", format: .securityCode)
  }
  .font(.title)
}
