import Foundation

struct SpecifyColor: Decodable {
    let name: String
    let rgbaValue: RGBAValue

    enum CodingKeys: String, CodingKey {
        case name
        case rgbaValue = "value"
    }
}
