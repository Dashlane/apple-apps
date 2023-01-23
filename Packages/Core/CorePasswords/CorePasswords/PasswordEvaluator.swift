import Foundation
import JavaScriptCore

private let zxcvbnJSFunctionName = "zxcvbn"
private let zxcvbnJSFileName = "zxcvbn"

public protocol PasswordEvaluatorProtocol {
    func evaluate(_ password: String) -> PasswordEvaluation
}

public struct PasswordEvaluator: PasswordEvaluatorProtocol {
    
    public typealias Password = String

    private let context: JSContext
        private static let maxLength = 50

    public init() throws {
        guard let zxcvbnURL = Bundle.module.url(forResource: zxcvbnJSFileName, withExtension: "js")?.absoluteURL else {
            fatalError("Unable to find zxcvbn.js file")
        }
        guard let context = JSContext() else {
            fatalError("Unable to initialise JSContext")
        }
        let jsContent = try String(contentsOf: zxcvbnURL)
        
        _ = context.evaluateScript(jsContent)
        self.context = context
    }

    public func evaluate(_ password: Password) -> PasswordEvaluation {
                let passwordToEvaluate = password.prefix(PasswordEvaluator.maxLength)
        let passwordEvaluatorFunc = context.objectForKeyedSubscript(zxcvbnJSFunctionName)
        
        guard let result = passwordEvaluatorFunc?.call(withArguments: [passwordToEvaluate]) else {
            return PasswordEvaluation()
        }
        
        return PasswordEvaluation(strength: passwordStrength(from: result),
                                  feedback: passwordFeedback(from: result))
    }
    
                    private func passwordStrength(from result: JSValue) -> PasswordStrength {
        let score = result.objectForKeyedSubscript("score").toInt32()
        
        return PasswordStrength(rawValue: Int(score)) ?? .veryGuessable
    }
    
                    private func passwordFeedback(from result: JSValue) -> PasswordFeedback {
        guard let feedbackObject = result.objectForKeyedSubscript("feedback") else {
            return PasswordFeedback()
        }
        let warningString = feedbackObject.objectForKeyedSubscript("warning")?.toString()
        let suggestionStrings = feedbackObject.objectForKeyedSubscript("suggestions")?.toArray() as? [String] ?? []
        
        let warning: PasswordFeedback.Warning? = (warningString != nil) ? PasswordFeedback.Warning.init(rawValue: warningString!) : nil
        let suggestions = suggestionStrings.compactMap { PasswordFeedback.Suggestion(rawValue: $0) }
        
        return PasswordFeedback(warning: warning,
                                suggestions: suggestions)
    }

}


private struct FakePasswordEvaluator: PasswordEvaluatorProtocol {
    func evaluate(_ password: String) -> PasswordEvaluation {
                let hasDigits = password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        let hasLowercase = password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
        let hasUppercase = password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
        let hasSpecialChar = password.rangeOfCharacter(from: CharacterSet.symbols) != nil
        if hasDigits, hasLowercase, hasUppercase, hasSpecialChar {
            return PasswordEvaluation(strength: .veryUnguessable)
        } else if hasDigits, (hasLowercase || hasUppercase), hasSpecialChar {
            return PasswordEvaluation(strength: .safelyUnguessable)
        } else if hasDigits, (hasLowercase || hasUppercase) {
            return PasswordEvaluation(strength: .somewhatGuessable)
        } else if password.count > 6 {
            return PasswordEvaluation(strength: .tooGuessable)
        } else {
            return PasswordEvaluation(strength: .veryGuessable)
        }
    }
}

public extension PasswordEvaluator {
    static var mock: PasswordEvaluatorProtocol {
        FakePasswordEvaluator()
    }
}
