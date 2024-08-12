import Foundation

public class CreditCardNumberFormatter: Formatter {
  var obfuscate = false
  var obfuscatingString = "•"
  public init(obfuscate: Bool = false, obfuscatingString: String = "•") {
    self.obfuscate = obfuscate
    self.obfuscatingString = obfuscatingString
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override public func string(for obj: Any?) -> String? {
    guard let creditCardNumber = obj as? String else {
      return nil
    }

    var formattedNumber = creditCardNumber.components(separatedBy: .whitespaces).joined()

    guard formattedNumber.count > 0 else {
      return ""
    }

    for currentIndex in indexesOfSpacesToInsert(for: formattedNumber) {
      formattedNumber.insert(" ", at: currentIndex)
    }

    if obfuscate {
      let lastSpaceIndex =
        formattedNumber.lastIndex(of: " ")
        ?? formattedNumber.index(before: formattedNumber.endIndex)

      var obfuscatedString = String(formattedNumber[...lastSpaceIndex])
      obfuscatedString = obfuscatedString.map {
        $0 == " " ? " " : obfuscatingString
      }.joined()

      let indexAfterLastSpace = formattedNumber.index(after: lastSpaceIndex)
      obfuscatedString = obfuscatedString.appending(formattedNumber[indexAfterLastSpace...])
      formattedNumber = obfuscatedString
    }

    return formattedNumber
  }

  private func indexesOfSpacesToInsert(for number: String) -> [String.Index] {
    let intIndices: [Int]
    switch number.count {
    case 16:
      intIndices = [12, 8, 4]
    case 13:
      intIndices = [10, 7, 4]
    case 4...15:
      intIndices = [10, 4].filter { $0 < number.count - 1 }
    default:
      intIndices = Array(stride(from: number.count - 1, to: 1, by: -4))
    }

    return intIndices.sorted(by: >).map { number.index(number.startIndex, offsetBy: $0) }
  }

  override public func getObjectValue(
    _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String,
    errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
  ) -> Bool {
    obj?.pointee = string as NSString
    return true
  }

}
