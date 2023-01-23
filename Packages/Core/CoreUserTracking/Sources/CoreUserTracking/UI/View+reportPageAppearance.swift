import Foundation
import SwiftUI
import DashTypes


public extension View {
        func reportPageAppearance(_ page: Page) -> some View {
        return modifier(PageAppearanceReporterViewModifier(page: page))
    }
}

private struct PageAppearanceReporterViewModifier: ViewModifier {
    let page: Page

    @GlobalEnvironment(\.report)
    var globalReport

    @Environment(\.report)
    var localReport

    var report: ReportAction? {
        localReport ?? globalReport
    }

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

private extension EnvironmentValues {
    var isPreview: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}
