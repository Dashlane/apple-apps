import Foundation

public struct DataReplacement: Hashable {
    let range: CountableRange<Int>
    let data: Data

    public init(_ data: Data, startLocation: Int) throws {
        self.data = data
        self.range = startLocation ..< (data.count + startLocation)
    }
}

public final class StreamEditor: StreamTransfer {

        private var changes: Set<DataReplacement> = Set()

        var accumulatedRange = 0..<0

        var accumulatedBytes = [UInt8]()

    public override init(source: URL,
                  destination: URL,
                  chunkSize: Int = 2048,
                  queue: DispatchQueue = DispatchQueue.global(),
                  completionHandler: StreamTransferCompletionHandler?) throws {
        try super.init(source: source,
                   destination: destination,
                   chunkSize: chunkSize,
                   queue: queue,
                   completionHandler: completionHandler)
    }

                public func add(replacement: DataReplacement) {
        changes.insert(replacement)
    }

    public override func process(bytes: [UInt8]) throws -> [UInt8]? {
                accumulate(bytes)

                                guard isAccumulatedBytesWritable() else {
            return nil
        }

                let replacementsToApply: [DataReplacement] = changes.filter { replacement in
            accumulatedRange.contains(range: replacement.range)
        }

                accumulatedBytes = update(bytes: accumulatedBytes, withReplacements: replacementsToApply)

                changes = changes.subtracting(replacementsToApply)

                let returnBytes = accumulatedBytes
        resetAccumulatedValues()
        return returnBytes
    }

                private func accumulate(_ bytes: [UInt8]) {
        accumulatedBytes += bytes
        accumulatedRange = accumulatedRange.lowerBound..<(accumulatedRange.upperBound + bytes.count)
    }

                            private func update(bytes: [UInt8], withReplacements replacements: [DataReplacement]) -> [UInt8] {
        var updatedBytes = bytes
        replacements.forEach { replacement in
            updatedBytes.replaceSubrange(replacement.range.shift(by: accumulatedRange.lowerBound), with: [UInt8](replacement.data))
        }
        return updatedBytes
    }

        private func resetAccumulatedValues() {
        accumulatedRange = accumulatedRange.upperBound..<accumulatedRange.upperBound
        accumulatedBytes = []
    }

                private func isAccumulatedBytesWritable() -> Bool {
        return accumulatedRange.crossesBounds(withAnyRange: changes.map { $0.range }) == false
    }
}

extension CountableRange where Bound == Int {
    func shift(by value: Bound) -> CountableRange<Bound> {
        return (self.lowerBound-value)..<(self.upperBound-value)
    }
    func contains(range: CountableRange<Bound>) -> Bool {
        guard range.lowerBound >= self.lowerBound &&
            range.upperBound <= self.upperBound else {
                return false
        }
        return true
    }
    func contains(range: CountableClosedRange<Bound>) -> Bool {
        guard range.lowerBound >= self.lowerBound &&
            range.upperBound < self.upperBound else {
                return false
        }
        return true
    }
    func crossesBounds(withRange range: CountableRange<Bound>) -> Bool {
        if range.upperBound <= self.lowerBound {
            return false
        } else if range.lowerBound >= self.upperBound {
            return false
        } else if range.lowerBound >= self.lowerBound &&
            range.upperBound <= self.upperBound {
            return false
        } else {
            return true
        }
    }
    func crossesBounds(withRange range: CountableClosedRange<Bound>) -> Bool {
        if range.upperBound < self.lowerBound {
            return false
        } else if range.lowerBound >= self.upperBound {
            return false
        } else if range.lowerBound >= self.lowerBound &&
            range.upperBound <= self.upperBound {
            return false
        } else {
            return true
        }
    }
    func crossesBounds(withAnyRange ranges: [CountableRange<Bound>]) -> Bool {
        return ranges
            .filter(crossesBounds)
            .count != 0
    }
    func crossesBounds(withAnyRange ranges: [CountableClosedRange<Bound>]) -> Bool {
        return ranges
            .filter(crossesBounds)
            .count != 0
    }

}
