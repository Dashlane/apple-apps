import Foundation

enum ColorValueFormatError: Error, CustomStringConvertible {
    case redValueOutsideExpectedBounds
    case greenValueOutsideExpectedBounds
    case blueValueOutsideExpectedBounds
    case alphaValueOutsideExpectedBounds

    var description: String {
        switch self {
        case .redValueOutsideExpectedBounds:
            return "Red value outside allowed bounds (0..255) for one of the colors. Please fix to proceed."
        case .greenValueOutsideExpectedBounds:
            return "Green value outside allowed bounds (0..255) for one of the colors. Please fix to proceed."
        case .blueValueOutsideExpectedBounds:
            return "Blue value outside allowed bounds (0..255) for one of the colors. Please fix to proceed."
        case .alphaValueOutsideExpectedBounds:
            return "Alpha value outside allowed bounds (0..1) for one of the colors. Please fix to proceed."
        }
    }
}
