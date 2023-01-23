import Foundation

struct ColorFile: Encodable {
    let colors: [ColorElement]
    let info: Info = Info()
    
    init(lightModeColor: RGBAValue, darkModeColor: RGBAValue) {
        self.colors = [
            ColorElement(mode: .light, rgbaValue: lightModeColor),
            ColorElement(mode: .dark, rgbaValue: darkModeColor)
        ]
    }
}

struct ColorElement: Encodable {
    let appearances: [DarkModeAppearance]?
    let color: ColorEntry
    let idiom: String = "universal"
    
    init(mode: UserInterfaceStyle, rgbaValue: RGBAValue) {
        self.appearances = mode == .dark ? [DarkModeAppearance()] : nil
        self.color = ColorEntry(rgbaValue: rgbaValue)
    }
}

struct DarkModeAppearance: Encodable {
    let appearance: String = "luminosity"
    let value: String = "dark"
}

struct ColorEntry: Encodable {
    let colorSpace: String = "srgb"
    let components: Components

    enum CodingKeys: String, CodingKey {
        case colorSpace = "color-space"
        case components
    }
    
    init(rgbaValue: RGBAValue) {
        self.components = Components(value: rgbaValue)
    }
}

struct Components: Encodable {
    let value: RGBAValue
    
    enum CodingKeys: CodingKey {
        case alpha
        case blue
        case green
        case red
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(format: "%.3f", value.alpha), forKey: .alpha)
        try container.encode(String(value.blue), forKey: .blue)
        try container.encode(String(value.green), forKey: .green)
        try container.encode(String(value.red), forKey: .red)
    }
}
