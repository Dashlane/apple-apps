import Foundation

struct Levenshtein {

							static func distance(between source: String, and target: String, limitedBy threshold: Int) -> Int {

				precondition(threshold >= 0)

		var mutableSource = Array(source)
		var mutableTarget = Array(target)

		var sourceLength = source.count
		var targetLength = target.count

				if sourceLength == 0 {
			return targetLength <= threshold ? targetLength : -1
		} else if targetLength == 0 {
			return sourceLength <= threshold ? targetLength: -1
		}

				if sourceLength > targetLength {
			swap(&mutableSource, &mutableTarget)
			sourceLength = targetLength
			targetLength = mutableTarget.count
		}

		let boundary = min(sourceLength, threshold) + 1

				var p = [Int](repeating: Int.max, count: sourceLength + 1)
				var d = [Int](repeating: Int.max, count: sourceLength + 1)

		for i in 0..<boundary {
			p[i] = i
		}

				for j in 1...targetLength {

			d[0] = j

						let min = Swift.max(1, j - threshold)
			let max: Int = (j > Int.max - threshold) ? sourceLength : Swift.min(sourceLength, j + threshold)

						guard min <= max else { return -1 }

						if min > 1 {
				d[min - 1] = Int.max
			}

						for i in min...max {
								if mutableSource[i - 1] == mutableTarget[j - 1] {
					d[i] = p[i - 1]
				} else {
															d[i] = 1 + Swift.min(d[i - 1], p[i], p[i - 1])
				}
			}
						swap(&p, &d)
		}

				if p[sourceLength] <= threshold {
			return p[sourceLength]
		}
		return -1
	}
}
