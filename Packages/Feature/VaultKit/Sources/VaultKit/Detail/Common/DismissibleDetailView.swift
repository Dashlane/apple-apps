#if os(iOS)
import Foundation
import SwiftUI
import UIComponents

public protocol DismissibleDetailView {
    var navigator: () -> Navigator? { get }
    var dismissAction: DismissAction { get }
    var dismissView: DetailContainerViewSpecificAction? { get }
}

public extension DismissibleDetailView {
    func dismiss() {
        if let dismissView {
            dismissView()
        } else if let navigator = navigator(), navigator.canDismiss == true {
            navigator.dismiss()
        } else {
            dismissAction()
        }
    }
}
#endif
