import Foundation

struct IconMetadata: Encodable {
    struct Image: Encodable {
        let filename: String
        let idiom = "universal"

        init(filename: String) {
            self.filename = filename
        }
    }

    struct Properties: Encodable {
        let preservesVectorRepresentation = true
        let templateRenderingIntent = "template"

        enum CodingKeys: String, CodingKey {
            case preservesVectorRepresentation = "preserves-vector-representation"
            case templateRenderingIntent = "template-rendering-intent"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(preservesVectorRepresentation, forKey: .preservesVectorRepresentation)
            try container.encode(templateRenderingIntent, forKey: .templateRenderingIntent)
        }
    }

    let images: [Image]
    let info = Info()
    let properties = Properties()

    init(filename: String) {
        self.images = [Image(filename: filename)]
    }
}
