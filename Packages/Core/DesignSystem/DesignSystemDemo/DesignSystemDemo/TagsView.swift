import SwiftUI
import DesignSystem

struct TagsView: View {
    enum ViewConfiguration: String, CaseIterable {
        case lightAppearance
        case darkAppearance
        case smallestDynamicTypeSize
        case largestDynamicTypeSize
    }
    
    var viewConfiguration: ViewConfiguration? {
        guard let configuration = ProcessInfo.processInfo.environment["tagsConfiguration"]
        else { return nil }
        return ViewConfiguration(rawValue: configuration)
    }
    
    var body: some View {
        switch viewConfiguration {
            case .lightAppearance:
                commonView
                    .preferredColorScheme(.light)
            case .darkAppearance:
                commonView
                    .preferredColorScheme(.dark)
            case .smallestDynamicTypeSize:
                commonView
                    .dynamicTypeSize(.xSmall)
            case .largestDynamicTypeSize:
                commonView
                    .dynamicTypeSize(.accessibility5)
                
            case .none:
               EmptyView()
        }
    }
    
    private var commonView: some View {
        VStack {
            Tag("Business")
            Tag("Shopping", leadingAccessory: .emoji("🛒"))
            Tag(
                "Travel",
                leadingAccessory: .emoji("✈️"),
                trailingAccessory: .icon(.ds.shared.outlined)
            )
            Tag("Finance", trailingAccessory: .icon(.ds.shared.outlined))
        }
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        TagsView()
    }
}
