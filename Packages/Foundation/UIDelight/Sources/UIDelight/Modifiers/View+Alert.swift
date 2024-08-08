import Foundation
import SwiftUI

public struct AlertContent: Identifiable {
  public enum ButtonsConfiguration {
    public struct Button {
      let title: String
      let action: () -> Void

      public init(title: String, action: @escaping () -> Void = {}) {
        self.title = title
        self.action = action
      }
    }

    case one(Button)
    case two(primaryButton: Button, secondaryButton: Button)
  }

  public var id: String {
    return title + (message.map { $0 } ?? "")
  }

  public let title: String
  public let message: String?
  public let buttons: ButtonsConfiguration?

  public init(
    title: String, message: String? = nil, buttons: AlertContent.ButtonsConfiguration? = nil
  ) {
    self.title = title
    self.message = message
    self.buttons = buttons
  }
}

extension View {
  @ViewBuilder
  public func alert(presenting alertContent: Binding<AlertContent?>) -> some View {
    self.alert(
      Text(alertContent.wrappedValue?.title ?? ""),
      isPresented: .init(
        get: { alertContent.wrappedValue != nil },
        set: { if !$0 { alertContent.wrappedValue = nil } }
      ),
      presenting: alertContent.wrappedValue,
      actions: {
        switch $0?.buttons {
        case .one(let dismissButtonContent):
          Button(dismissButtonContent.title, action: dismissButtonContent.action)
        case .two(let primaryButtonContent, let secondaryButtonContent):
          Button(primaryButtonContent.title, action: primaryButtonContent.action)
          Button(secondaryButtonContent.title, action: secondaryButtonContent.action)
        case .none:
          EmptyView()
        }
      },
      message: { Text($0?.message ?? "") }
    )
  }
}

extension View {
  public func alert<Value>(using value: Binding<Value?>, content: (Value) -> Alert) -> some View {
    let binding = Binding<Bool>(
      get: { value.wrappedValue != nil },
      set: { _ in value.wrappedValue = nil }
    )
    return background(
      EmptyView()
        .alert(isPresented: binding) {
          content(value.wrappedValue!)
        }
    )
  }
}
