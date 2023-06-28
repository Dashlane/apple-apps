import Foundation

extension Definition {

public enum `EmailDomainError`: String, Encodable {
case `incorrectText` = "incorrect_text"
case `notFound` = "not_found"
case `otherError` = "other_error"
}
}