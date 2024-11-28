import SwiftUI

@main
struct DesignSystemDemoApp: App {
  private enum Mode: String, CaseIterable {
    case badges
    case bottomSheets
    case buttons
    case infobox
    case linkButtons
    case listItems
    case obfuscatedDisplayFields
    case tags
    case textAreas
    case textFields
    case thumbnails
    case toggles
  }

  private var mode: Mode? {
    return Mode.allCases.first {
      ProcessInfo.processInfo.environment["\($0.rawValue)Configuration"] != nil
    }
  }

  var body: some Scene {
    WindowGroup {
      VStack(spacing: 0) {
        switch mode {
        case .badges:
          BadgesView()
        case .bottomSheets:
          BottomSheetsView()
        case .buttons:
          ButtonsView()
        case .infobox:
          InfoboxView()
        case .linkButtons:
          LinkButtonsView()
        case .listItems:
          ListItemsView()
        case .obfuscatedDisplayFields:
          ObfuscatedDisplayFieldsView()
        case .tags:
          TagsView()
        case .textAreas:
          TextAreasView()
        case .textFields:
          TextFieldsView()
        case .thumbnails:
          ThumbnailsView()
        case .toggles:
          TogglesView()
        case .none:
          EmptyView()
        }
      }
      .statusBar(hidden: true)
    }
  }
}
