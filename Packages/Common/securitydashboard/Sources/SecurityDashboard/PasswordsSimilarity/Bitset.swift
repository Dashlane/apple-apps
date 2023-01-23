import Foundation

struct Bitset {

		private let bitsetSize = 32

		typealias Word = UInt32

		private let size: Int

		private var bitset: [Word]

		var count: Int {
		return self.bitset.reduce(0) { $0 + $1.nonzeroBitCount }
	}

		var any: Bool {
		return self.bitset.first { $0.nonzeroBitCount > 0 } != nil
	}

		var none: Bool { return !self.any }

		init(size: Int) {
		self.size = size
		let numberOfValues = (size + (bitsetSize - 1)) / bitsetSize
		self.bitset = [Word].init(repeating: 0, count: numberOfValues)
	}

	public subscript(index: Int) -> Bool {
		get { return isSet(index) }
		set { if newValue { set(index) } else { clear(index) } }
	}

		mutating func set(_ index: Int) {
		let (j, m) = indexOf(index)
		bitset[j] |= m
	}

		func isSet(_ index: Int) -> Bool {
		let (j, m) = indexOf(index)
		return (bitset[j] & m) != 0
	}

		public mutating func clear(_ index: Int) {
		let (j, m) = indexOf(index)
		bitset[j] &= ~m
	}

		private func indexOf(_ index: Int) -> (Int, Word) {
		let o = index / self.bitsetSize
		let m = Word(index - o * self.bitsetSize)
		return (o, 1 << m)
	}
}

extension Bitset {

	static func & (lhs: Bitset, rhs: Bitset) -> Bitset {
		let m = max(lhs.size, rhs.size)
		var out = Bitset(size: m)
		let n = min(lhs.bitset.count, rhs.bitset.count)
		for i in 0..<n {
			out.bitset[i] = lhs.bitset[i] & rhs.bitset[i]
		}
		return out
	}

	static prefix func ~ (rhs: Bitset) -> Bitset {
		var out = Bitset(size: rhs.size)
		for i in 0..<rhs.bitset.count {
			out.bitset[i] = ~rhs.bitset[i]
		}
		return out
	}

}
