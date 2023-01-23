import Foundation

extension Definition {

public struct `Duration`: Encodable {
public init(`chronological`: Int, `sharing`: Int, `sync`: Int, `treatProblem`: Int) {
self.chronological = chronological
self.sharing = sharing
self.sync = sync
self.treatProblem = treatProblem
}
public let chronological: Int
public let sharing: Int
public let sync: Int
public let treatProblem: Int
}
}