import Foundation
import SwiftUI
import UIComponents

public protocol DismissibleDetailView {
  var dismissAction: DismissAction { get }
  var dismissView: DetailContainerViewSpecificAction? { get }
}

extension DismissibleDetailView {
  public func dismiss() {
    if let dismissView {
      dismissView()
    } else {
      dismissAction()
    }
  }
}
