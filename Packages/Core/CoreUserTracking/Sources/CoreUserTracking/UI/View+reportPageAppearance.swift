import DashTypes
import Foundation
import SwiftUI

extension View {
  public func reportPageAppearance(_ page: Page) -> some View {
    return modifier(PageAppearanceReporterViewModifier(page: page))
  }
}

private struct PageAppearanceReporterViewModifier: ViewModifier {
  let page: Page

  @Environment(\.report)
  var report

  @Environment(\.isPreview)
  var isPreview

  func body(content: Content) -> some View {
    content.onAppear {

      if !ProcessInfo.processInfo.isPreview {
        assert(report != nil, "The report action should be set")
      }

      report?(page)
    }
  }
}

extension EnvironmentValues {
  fileprivate var isPreview: Bool {
    #if DEBUG
      return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    #else
      return false
    #endif
  }
}
