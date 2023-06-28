import SwiftUI

@main
struct DesignSystemDemoApp: App {
    private enum Mode: String, CaseIterable {
        case infobox
        case buttons
        case textFields
        case badges
        case toggles
        case tags
    }

    private var mode: Mode? {
        return Mode.allCases.first { ProcessInfo.processInfo.environment["\($0.rawValue)Configuration"] != nil }
    }
    
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                switch mode {
                    case .infobox:
                        InfoboxView()
                    case .buttons:
                        ButtonsView()
                    case .badges:
                        BadgesView()
                    case .textFields:
                        TextFieldsView()
                    case .toggles:
                        TogglesView()
                    case .tags:
                        TagsView()
                    case .none:
                        EmptyView()
                }
            }
            .statusBar(hidden: true)
        }
    }
}
