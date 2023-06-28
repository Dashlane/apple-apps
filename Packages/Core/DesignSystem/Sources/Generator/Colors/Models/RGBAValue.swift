import Foundation

struct RGBAValue: Decodable {
    let red: Int
    let green: Int
    let blue: Int
    let alpha: Double

    enum CodingKeys: CodingKey {
        case r
        case g
        case b
        case a
    }

    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let red = try keyedContainer.decode(Int.self, forKey: .r)
        let green = try keyedContainer.decode(Int.self, forKey: .g)
        let blue = try keyedContainer.decode(Int.self, forKey: .b)
        let alpha = try keyedContainer.decode(Double.self, forKey: .a)

        try self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(red: Int, green: Int, blue: Int, alpha: Double) throws {
        guard red.isWithinBoundsForRGBValue else {
            throw ColorValueFormatError.redValueOutsideExpectedBounds
        }

        guard green.isWithinBoundsForRGBValue else {
            throw ColorValueFormatError.greenValueOutsideExpectedBounds
        }

        guard blue.isWithinBoundsForRGBValue else {
            throw ColorValueFormatError.blueValueOutsideExpectedBounds
        }

        guard alpha.isWithinBoundsForAlphaValue else {
            throw ColorValueFormatError.alphaValueOutsideExpectedBounds
        }

        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

private extension Int {
    var isWithinBoundsForRGBValue: Bool {
        return self >= 0 && self <= 255
    }
}

private extension Double {
    var isWithinBoundsForAlphaValue: Bool {
        return self >= 0 && self <= 1
    }
}
