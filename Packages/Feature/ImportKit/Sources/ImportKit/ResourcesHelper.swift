import SwiftUI

extension SwiftUI.Image {
    init(_ imageAsset: ImageAsset) {
        self.init(imageAsset.name, bundle: Bundle.module)
    }
}
