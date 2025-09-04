import CoreLocalization
import DesignSystemExtra
import SwiftUI
import UIComponents
import VaultKit

public struct DetailFieldActionSheet: ViewModifier {

  public enum Action {
    case copy((_ value: String, _ fieldType: DetailFieldType) -> Void)
    case largeDisplay
  }

  let title: String
  @Binding
  var text: String
  let actions: [DetailFieldActionSheet.Action]
  let hasAccessory: Bool

  @State
  var showActionSheet: Bool = false

  @State
  var showLargeDisplay: Bool = false

  @Environment(\.detailMode)
  var detailMode

  @Environment(\.sizeCategory)
  var sizeCategory

  @Environment(\.detailFieldType)
  var fieldType

  @ViewBuilder
  public func body(content: Content) -> some View {
    Group {
      if detailMode.isEditing {
        content
      } else {

        #if targetEnvironment(macCatalyst)
          content
            .contextMenu {
              if self.actions.copyAction != nil {
                Button(CoreL10n.kwCopy, action: copy)
              }
              if self.actions.hasLargeDisplay {
                Button(
                  L10n.Localizable.editMenuShowLargeCharacters,
                  action: {
                    showLargeDisplay = true
                  })
              }
            }
        #else
          content
            .contentShape(Rectangle())
            .onTapGesture {
              if !self.text.isEmpty && !self.actions.isEmpty {
                self.showActionSheet = true
              }
            }
            .onLongPressGesture {
              if !self.text.isEmpty && self.actions.hasLargeDisplay {
                showLargeDisplay = true
              }
            }.actionSheet(isPresented: self.$showActionSheet) {
              self.detailFieldActionSheet
            }
        #endif
      }
    }
    .overFullScreen(isPresented: $showLargeDisplay) {
      NativeLargeDisplayAlert(text)
        .onTapGesture {
          self.showLargeDisplay = false
        }
    }
    .onReceive(
      NotificationCenter.default.publisher(
        for: UIApplication.applicationWillResignActiveNotification)
    ) { _ in
      self.showLargeDisplay = false
    }
  }

  private func copy() {
    self.actions.copyAction?(self.text, self.fieldType)
  }
}

extension DetailFieldActionSheet {
  private var detailFieldActionSheet: ActionSheet {
    ActionSheet(title: Text(title), message: nil, buttons: actionButtons)
  }

  private var actionButtons: [ActionSheet.Button] {

    var buttons: [ActionSheet.Button] = actions.map { action in
      switch action {
      case .copy(let action):
        return copyButton(action: action)
      case .largeDisplay:
        return largeDisplayButton
      }
    }
    buttons.append(.cancel())
    return buttons
  }

  private func copyButton(action: @escaping (String, DetailFieldType) -> Void) -> ActionSheet.Button
  {
    .default(
      Text(CoreL10n.kwCopy),
      action: {
        action(self.text, self.fieldType)
      })
  }

  private var largeDisplayButton: ActionSheet.Button {
    .default(Text(L10n.Localizable.editMenuShowLargeCharacters)) {
      showLargeDisplay = true
    }
  }
}

extension CopiableDetailField {
  public func actions(
    _ actions: [DetailFieldActionSheet.Action],
    hasAccessory: Bool = true
  ) -> some View {
    self.modifier(
      DetailFieldActionSheet(
        title: title,
        text: copiableValue,
        actions: actions,
        hasAccessory: hasAccessory))
  }

}

extension Array where Element == DetailFieldActionSheet.Action {
  var copyAction: ((String, DetailFieldType) -> Void)? {
    var result: ((String, DetailFieldType) -> Void)?
    self.forEach {
      switch $0 {
      case .copy(let action):
        result = action
      default: break
      }
    }
    return result
  }

  var hasLargeDisplay: Bool {
    var result = false
    self.forEach {
      switch $0 {
      case .largeDisplay:
        result = true
      default: break
      }
    }
    return result
  }
}
