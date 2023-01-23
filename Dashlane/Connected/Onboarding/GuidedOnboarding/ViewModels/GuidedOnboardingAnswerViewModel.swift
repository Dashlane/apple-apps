import Foundation
import SwiftUI

class GuidedOnboardingAnswerViewModel: Identifiable, ObservableObject, Equatable {

    let content: GuidedOnboardingAnswer

    @Published
    var isExpanded: Bool = false
    @Published
    var isInvisible: Bool = false
    @Published
    var isHidden: Bool = false
    @Published
    var tintColor: Color = Color(asset: FiberAsset.mainGreen)

    init(content: GuidedOnboardingAnswer) {
        self.content = content
    }

    static func == (lhs: GuidedOnboardingAnswerViewModel, rhs: GuidedOnboardingAnswerViewModel) -> Bool {
        return lhs.content == rhs.content
    }
}
