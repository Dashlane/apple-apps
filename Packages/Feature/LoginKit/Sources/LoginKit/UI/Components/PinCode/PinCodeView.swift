import CoreLocalization
import DesignSystem
import Foundation
import SwiftUI
import UIDelight

public struct PinCodeView: View {
  let length: Int
  let attempt: Int
  @Binding
  var errorMessage: String
  let cancelAction: () -> Void
  @Binding
  var pinCode: String {
    didSet {
      if pinCode.count > length {
        pinCode = oldValue
      }
    }
  }
  let hideCancel: Bool

  public init(
    pinCode: Binding<String>,
    errorMessage: Binding<String> = .constant(""),
    length: Int,
    attempt: Int,
    hideCancel: Bool = false,
    cancelAction: @escaping () -> Void
  ) {
    self._pinCode = pinCode
    self._errorMessage = errorMessage
    self.length = length
    self.attempt = attempt
    self.cancelAction = cancelAction
    self.hideCancel = hideCancel
  }

  public var body: some View {
    VStack(alignment: .center, spacing: 22) {
      VStack(spacing: 16) {
        HStack(spacing: 29) {
          ForEach(1...length, id: \.self) { value in
            let strokeColor: Color =
              pinCode.count >= value ? .ds.text.neutral.standard : .ds.border.neutral.standard.idle
            let fillColor: Color = pinCode.count >= value ? .ds.text.neutral.standard : .clear

            Circle()
              .stroke(strokeColor, lineWidth: 1)
              .fill(fillColor)
              .frame(width: 12, height: 12)
          }
        }
        .shakeAnimation(forNumberOfAttempts: attempt)
        Text(errorMessage)
          .foregroundStyle(Color.ds.text.danger.quiet)
          .font(.body)
          .multilineTextAlignment(.center)
      }

      VStack(alignment: .trailing, spacing: 16) {

        HStack(spacing: 16) {
          ForEach(1..<4) { value in
            PinButton(action: { self.didClickCode(value) }, title: String(value)).font(.title)
              .keyboardShortcut(.init(value), modifiers: [])
          }
        }
        HStack(spacing: 16) {
          ForEach(4..<7) { value in
            PinButton(action: { self.didClickCode(value) }, title: String(value)).font(.title)
              .keyboardShortcut(.init(value), modifiers: [])
          }
        }
        HStack(spacing: 16) {
          ForEach(7..<10) { value in
            PinButton(action: { self.didClickCode(value) }, title: String(value)).font(.title)
              .keyboardShortcut(.init(value), modifiers: [])
          }
        }
        HStack(spacing: 16) {
          PinButton(action: {}, title: "").hidden()
          PinButton(action: { self.didClickCode(0) }, title: "0").font(.title)
            .keyboardShortcut(.init(0), modifiers: [])
          if pinCode.count == 0 {
            if hideCancel {
              cancelButton
                .hidden()
            } else {
              cancelButton
            }
          } else {
            deleteButton
          }
        }
      }
      .disabled(pinCode.count >= length)

    }
    .padding(.all, 16)
    .animation(.default, value: length)
  }

  var cancelButton: some View {
    PinButton(
      action: cancelAction,
      title: CoreL10n.cancel,
      fillColor: .clear,
      highlightColor: .clear
    )
    .keyboardShortcut(KeyEquivalent.escape, modifiers: [])
    .font(.caption)
    .foregroundStyle(Color.ds.text.neutral.standard)
  }

  var deleteButton: some View {
    PinButton(
      action: {
        if !self.pinCode.isEmpty {
          _ = self.pinCode.removeLast()
        }
      }, title: CoreL10n.kwDelete, fillColor: .clear, highlightColor: .clear
    ).font(.caption)
      .foregroundStyle(Color.ds.text.neutral.standard)
      .keyboardShortcut(KeyEquivalent.return, modifiers: [])
  }

  func didClickCode(_ code: Int) {
    self.pinCode += String(code)
  }

}

struct PinCodeView_Previews: PreviewProvider {

  static var previews: some View {

    PinCodeView(pinCode: .constant(""), length: 4, attempt: 1, cancelAction: {}).padding(
      .horizontal, 20
    ).loginAppearance()
    PinCodeView(pinCode: .constant("1"), length: 4, attempt: 0, cancelAction: {}).loginAppearance()
      .frame(width: 260, height: 318)
    PinCodeView(pinCode: .constant("12"), length: 4, attempt: 2, cancelAction: {}).frame(
      width: 200, height: 300
    ).loginAppearance()
    PinCodeView(pinCode: .constant("123"), length: 4, attempt: 2, cancelAction: {}).frame(
      width: 300, height: 400
    ).loginAppearance()
    PinCodeView(pinCode: .constant("1234"), length: 4, attempt: 2, cancelAction: {})
      .loginAppearance()
    PinCodeView(pinCode: .constant("123456789"), length: 6, attempt: 2, cancelAction: {})
      .loginAppearance()
  }
}

extension KeyEquivalent {
  fileprivate init(_ intValue: Int) {
    let char = Character("\(intValue)")
    self.init(unicodeScalarLiteral: char)
  }
}
