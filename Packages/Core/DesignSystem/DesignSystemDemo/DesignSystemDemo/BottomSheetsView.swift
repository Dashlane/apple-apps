import DesignSystem
import SwiftUI

struct BottomSheetsView: View {
  enum ViewConfiguration: String, CaseIterable {
    case regular
    case headerless
    case descriptionless
    case singleAction
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["bottomSheetsConfiguration"]
    else { return nil }
    return ViewConfiguration(rawValue: configuration)
  }

  var body: some View {
    switch viewConfiguration {
    case .regular:
      Button("Display sheet") {}
        .sheet(isPresented: .constant(true)) {
          BottomSheet(
            "Special Announcement",
            description: "We have something to announce, and it's great!",
            actions: {
              Button("Discard", action: {})
                .buttonStyle(.designSystem(.titleOnly))

              Button("Learn More", action: {})
                .buttonStyle(.designSystem(.titleOnly))
                .style(intensity: .quiet)
            },
            header: {
              Text("This is the header")
            }
          )
        }
    case .headerless:
      Button("Display sheet") {}
        .sheet(isPresented: .constant(true)) {
          BottomSheet(
            "Special Announcement",
            description: "We have something to announce, and it's great!",
            actions: {
              Button("Discard", action: {})
                .buttonStyle(.designSystem(.titleOnly))

              Button("Learn More", action: {})
                .buttonStyle(.designSystem(.titleOnly))
                .style(intensity: .quiet)
            }
          )
        }
    case .descriptionless:
      Button("Display sheet") {}
        .sheet(isPresented: .constant(true)) {
          BottomSheet(
            "Special Announcement",
            actions: {
              Button("Discard", action: {})
                .buttonStyle(.designSystem(.titleOnly))

              Button("Learn More", action: {})
                .buttonStyle(.designSystem(.titleOnly))
                .style(intensity: .quiet)
            }
          )
        }
    case .singleAction:
      Button("Display sheet") {}
        .sheet(isPresented: .constant(true)) {
          BottomSheet(
            "Special Announcement",
            description: "We have something to announce, and it's great!",
            actions: {
              Button("Discard", action: {})
                .buttonStyle(.designSystem(.titleOnly))
            }
          )
        }
    case .none:
      EmptyView()
    }
  }
}

struct BottomSheetsView_Previews: PreviewProvider {
  static var previews: some View {
    BottomSheetsView()
  }
}
