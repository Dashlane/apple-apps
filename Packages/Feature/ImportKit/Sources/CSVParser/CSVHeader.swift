public protocol CSVHeader {
    var rawValue: String { get }
    var isOptional: Bool { get }
}
