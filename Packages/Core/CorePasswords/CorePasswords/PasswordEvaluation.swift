import Foundation

@objc final public class PasswordEvaluation: NSObject {
    public let strength: PasswordStrength
    public let feedback: PasswordFeedback
    
    init(strength: PasswordStrength = .tooGuessable, feedback: PasswordFeedback = PasswordFeedback()) {
        self.strength = strength
        self.feedback = feedback
    }
}

@objc public enum PasswordStrength: Int, Comparable {
    
        case tooGuessable = 0
    
        case veryGuessable = 1
    
        case somewhatGuessable = 2
    
        case safelyUnguessable = 3
    
        case veryUnguessable = 4
    
        public var score: Int {
        return self.rawValue
    }
    
        public var percentScore: Int {
        return self.rawValue * 25
    }
    
    public static func < (lhs: PasswordStrength, rhs: PasswordStrength) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public var isWeak: Bool {
        return self < .somewhatGuessable
    }
}

@objc final public class PasswordFeedback: NSObject {
    public let warning: Warning?
    public let suggestions: [Suggestion]
    
    init(warning: Warning? = nil, suggestions: [Suggestion] = []) {
        self.warning = warning
        self.suggestions = suggestions
    }
    
    public enum Warning: String {
        case keyRow = "Straight rows of keys are easy to guess"
        case keyboardPattern = "Short keyboard patterns are easy to guess"
        case repeatedPattern = "Repeats like \"abcabcabc\" are only slightly harder to guess than \"abc\""
        case repeatedCharacter = "Repeats like \"aaa\" are easy to guess"
        case sequence = "Sequences like abc or 6543 are easy to guess"
        case recentYear = "Recent years are easy to guess"
        case date = "Dates are often easy to guess"
        case top10 = "This is a top-10 common password"
        case top100 = "This is a top-100 common password"
        case veryCommon = "This is a very common password"
        case similarToCommon = "This is similar to a commonly used password"
        case word = "A word by itself is easy to guess"
        case name = "Names and surnames by themselves are easy to guess"
        case commonName = "Common names and surnames are easy to guess"
    }
    
    public enum Suggestion: String {
        case avoidCommonPhrases = "Use a few words, avoid common phrases"
        case alphaIsEnough = "No need for symbols, digits, or uppercase letters"
        case addWords = "Add another word or two. Uncommon words are better."
        case improvedPattern = "Use a longer keyboard pattern with more turns"
        case avoidRepetition = "Avoid repeated words and characters"
        case avoidSequences = "Avoid sequences"
        case avoidRecentYear = "Avoid recent years"
        case avoidPersonalYears = "Avoid years that are associated with you"
        case avoidPersonalDates = "Avoid dates and years that are associated with you"
        case capitalization = "Capitalization doesn't help very much"
        case uppercaseEqualLowercase = "All-uppercase is almost as easy to guess as all-lowercase"
        case reversed = "Reversed words aren't much harder to guess"
        case predictableSubstitutions = "_"
    }
}
