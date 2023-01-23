import Foundation
import SwiftUI

@resultBuilder
public struct InfoboxButtonsBuilder {
    public typealias TextButton = Button<Text>
    
    public static func buildExpression(_ button: TextButton) -> [TextButton]  {
        [button]
    }

    public static func buildBlock(_ components: [TextButton]...) -> [TextButton] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ buttons: [TextButton]?) -> [TextButton] {
        buttons ?? []
    }

    public static func buildEither(first component: [TextButton]) -> [TextButton] {
        component
    }

    public static func buildEither(second component: [TextButton]) -> [TextButton] {
        component
    }
}

extension Infobox {

    private init(title: String,
                 description: String?,
                 buttons: [Button<Text>]) {
        self.title = title
        self.description = description

        self.firstButton = buttons.first
        self.secondButton = buttons.indices.contains(1) ? buttons[1] : nil
    }

                                                                                    public init(title: String, description: String? = nil) {
        self.init(title: title, description: description, buttons: [])
    }

                                                                                                                public init(title: String,
                description: String? = nil,
                @InfoboxButtonsBuilder buttons: () -> [Button<Text>]) {
        self.init(title: title, description: description, buttons: buttons())
    }
}
