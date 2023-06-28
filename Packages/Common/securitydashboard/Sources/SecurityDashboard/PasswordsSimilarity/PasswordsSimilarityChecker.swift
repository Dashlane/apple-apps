import Foundation

struct PasswordsSimilarityChecker {
		private typealias Pair = (value: Int, bitset: Bitset)

		struct IndicesGroup {
		public let possibleRoot: Int
        public let count: Int
		public var linkedIndices: [Int]
	}

    typealias Password = String
		typealias Group = (possibleRoot: Password, linkedPasswords: Set<Password>)

	    static let defaulMaxLevenshteinDistance: Int = 3

	    static let defaultMinCharCount: Int = 5

    private(set) var localCache: [Int: Bool]

    init(localCache: [Int: Bool] = [:]) {
        self.localCache = localCache
    }

        mutating func `is`(_ source: Password,
                       equivalentTo target: Password,
                       usingMaxLevenshteinDistance maxLevenshteinDistance: Int = Self.defaulMaxLevenshteinDistance,
                       minimumPasswordSize minimumSize: Int = Self.defaultMinCharCount) -> Bool {

                guard source.count >= minimumSize, target.count >= minimumSize else {
            return source == target
        }

		guard abs(source.count - target.count) <= maxLevenshteinDistance else {
			return false
		}

		let sourceTargetHash = Set([source, target]).hashValue

        if let alreadyComputed = self.localCache[sourceTargetHash] {
            return alreadyComputed
        }

        		let distance = Levenshtein.distance(between: source, and: target, limitedBy: maxLevenshteinDistance)
		let result = distance > -1 && distance <= maxLevenshteinDistance

        localCache[sourceTargetHash] = result

        return result
    }

            mutating func groupByIndices(_ passwords: [Password],
                                 usingMaxLevenshteinDistance maxLevenshteinDistance: Int = Self.defaulMaxLevenshteinDistance) -> [IndicesGroup] {

                var groups = [Pair].init(repeating: (0, Bitset.init(size: passwords.count)), count: passwords.count)

        for i in 0..<passwords.count {

						groups[i].value = i
			groups[i].bitset[i] = true

			for j in (i + 1)..<passwords.count where self.is(passwords[i], equivalentTo: passwords[j], usingMaxLevenshteinDistance: maxLevenshteinDistance) {
                                                groups[i].bitset[j] = true
                                groups[j].bitset[i] = true
            }
        }

				groups = groups.sorted { $0.bitset.count > $1.bitset.count }

				var i = 0
		while i < groups.count {
			var j = i + 1
			while j < groups.count {
				let firstPair = groups[i]
				let secondPair = groups[j]
                if (~firstPair.bitset & secondPair.bitset).none {
                    groups.remove(at: j)
                } else {
                    j += 1
                }
			}
			i += 1
		}

				var result = [IndicesGroup]()
		for group in groups {
			let finalGroup = passwords.enumerated().compactMap { group.bitset[$0.offset] ? $0.offset : nil }
						if finalGroup.count > 1 {
                result.append(IndicesGroup(possibleRoot: group.value, count: finalGroup.count, linkedIndices: finalGroup))
			}
		}

        return result
    }

        mutating func group(_ passwords: [Password],
                        usingMaxLevenshteinDistance maxLevenshteinDistance: Int = Self.defaulMaxLevenshteinDistance) -> [Group] {

		let groups: [Group] = groupByIndices(passwords, usingMaxLevenshteinDistance: maxLevenshteinDistance)
			.map { (passwords[$0.possibleRoot], 
				Set($0.linkedIndices.map { passwords[$0] })) } 

		return groups
    }

                        mutating func similarityCount(of password: Password,
                                  in dataSet: [Password],
                                  usingMaxLevenshteinDistance maxLevenshteinDistance: Int = Self.defaulMaxLevenshteinDistance,
                                  minimumPasswordSize minimumSize: Int = Self.defaultMinCharCount) -> Int {

        var contained = 0

        for matchingPassword in dataSet where self.is(password,
                                                      equivalentTo: matchingPassword,
                                                      usingMaxLevenshteinDistance: maxLevenshteinDistance,
                                                      minimumPasswordSize: minimumSize) {
            contained += 1
        }

        return contained
    }
}

extension PasswordsSimilarityChecker.IndicesGroup: Equatable {
    static func == (lhs: PasswordsSimilarityChecker.IndicesGroup, rhs: PasswordsSimilarityChecker.IndicesGroup) -> Bool {
        return lhs.possibleRoot == rhs.possibleRoot
            && lhs.count == rhs.count
            && lhs.linkedIndices == rhs.linkedIndices
    }

}
