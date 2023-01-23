import Foundation


actor PasswordsSimilarityOperation {
    private(set) var cache: [Int: Bool] = [:]

    @discardableResult
    func run<T>(_ handler: @Sendable (inout PasswordsSimilarityChecker) -> T) async -> T {
        var similarity = PasswordsSimilarityChecker(localCache: cache)
        let result = handler(&similarity)
        cache.merge(cache, uniquingKeysWith:  { _, newValue in newValue })
        return result
    }
}
