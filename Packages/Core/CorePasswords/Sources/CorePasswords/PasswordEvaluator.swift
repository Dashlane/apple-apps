import Foundation
import JavaScriptCore
import ZXCVBN

private let zxcvbnJSFunctionName = "zxcvbn"
private let zxcvbnJSFileName = "zxcvbn"
private let maxLength = 50

public protocol PasswordEvaluatorProtocol {
  func evaluate(_ password: String) -> PasswordStrength
}

public struct PasswordEvaluator: PasswordEvaluatorProtocol {

  public init() {}

  public func evaluate(_ password: String) -> PasswordStrength {
    JSPasswordEvaluator.default.evaluate(password)
  }
}

extension ZXCVBN: PasswordEvaluatorProtocol {
  public func evaluate(_ password: String) -> PasswordStrength {
    let passwordToEvaluate = password.prefix(maxLength)
    let result: ZXCVBN.Result = evaluate(passwordToEvaluate)

    return result.score
  }
}

public struct JSPasswordEvaluator: PasswordEvaluatorProtocol {
  public typealias Password = String

  private let context: JSContext

  static var `default` = try! JSPasswordEvaluator()

  public init() throws {
    guard
      let zxcvbnURL = Bundle.module.url(forResource: zxcvbnJSFileName, withExtension: "js")?
        .absoluteURL
    else {
      fatalError("Unable to find zxcvbn.js file")
    }
    guard let context = JSContext() else {
      fatalError("Unable to initialise JSContext")
    }
    let jsContent = try String(contentsOf: zxcvbnURL)

    _ = context.evaluateScript(jsContent)
    self.context = context
  }

  public func evaluate(_ password: Password) -> PasswordStrength {
    let passwordToEvaluate = password.prefix(maxLength)
    let passwordEvaluatorFunc = context.objectForKeyedSubscript(zxcvbnJSFunctionName)

    guard let result = passwordEvaluatorFunc?.call(withArguments: [passwordToEvaluate]) else {
      return .tooGuessable
    }

    return passwordStrength(from: result)
  }

  private func passwordStrength(from result: JSValue) -> PasswordStrength {
    let score = result.objectForKeyedSubscript("score").toInt32()

    return PasswordStrength(rawValue: Int(score)) ?? .veryGuessable
  }
}

public struct PasswordEvaluatorMock: PasswordEvaluatorProtocol {
  let strength: PasswordStrength?

  public func evaluate(_ password: String) -> PasswordStrength {
    if let strength {
      return strength
    } else {
      let hasDigits = password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
      let hasLowercase = password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
      let hasUppercase = password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
      let hasSpecialChar = password.rangeOfCharacter(from: CharacterSet.symbols) != nil
      if hasDigits, hasLowercase, hasUppercase, hasSpecialChar {
        return .veryUnguessable
      } else if hasDigits, hasLowercase || hasUppercase, hasSpecialChar {
        return .safelyUnguessable
      } else if hasDigits, hasLowercase || hasUppercase {
        return .somewhatGuessable
      } else if password.count > 6 {
        return .tooGuessable
      } else {
        return .veryGuessable
      }
    }
  }
}

extension PasswordEvaluatorProtocol where Self == PasswordEvaluatorMock {
  public static func mock(_ strength: PasswordStrength? = nil) -> PasswordEvaluatorMock {
    return PasswordEvaluatorMock(strength: strength)
  }
}
