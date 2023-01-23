import Foundation
import SwiftTreats

public class PasswordGuidelineViewModel: ObservableObject {
    let title: String
    let list: String
    let story: String?

    public init(title: String, list: String, story: String? = nil) {
        self.title = title
        self.list = list
        self.story = story
    }
}
