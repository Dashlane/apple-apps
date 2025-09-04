import Combine
import DesignSystem
import Foundation
import SwiftUI

public struct OTPInputField: View {
  let numberOfDigits: Int

  @Binding
  var otp: String

  @FocusState
  private var focusedField: Int?

  @Environment(\.isEnabled)
  var isGloballyEnabled

  public init(otp: Binding<String>, numberOfDigits: Int = 6) {
    _otp = otp
    self.numberOfDigits = numberOfDigits
  }

  public var body: some View {
    HStack(spacing: 8) {
      ForEach(0..<numberOfDigits, id: \.self) { index in
        let binding = binding(forIndex: index)

        OTPDigitField(value: binding)
          .focused($focusedField, equals: index)
          .disabled(!isGloballyEnabled || otp.count < index)
          .onChange(of: binding.wrappedValue) { _, newValue in
            changeFocusIfNeeded(forNewValue: newValue, atIndex: index)
          }
          .onChange(of: focusedField) { _, focusedField in
            guard focusedField == index else {
              return
            }
            binding.wrappedValue = ""
          }
          .onTapGesture {
            guard focusedField == nil, isGloballyEnabled else {
              return
            }

            focusedField = min(otp.count, index)
          }
      }
    }.onAppear {
      if otp.isEmpty {
        focusedField = 0
      }
    }
  }

  private func binding(forIndex index: Int) -> Binding<String> {
    Binding<String>(
      get: {
        guard index < otp.count else {
          return ""
        }

        return String(otp[otp.index(otp.startIndex, offsetBy: index)])
      },
      set: { newValue in
        let newValue = newValue.prefix(1)

        if Int(newValue) != nil {
          if otp.count <= index {
            otp.append(contentsOf: newValue)
          } else {
            let index = otp.index(otp.startIndex, offsetBy: index)
            otp.replaceSubrange(index...index, with: newValue)
          }
        } else if self.otp.count > index {
          otp = String(self.otp.prefix(index))
        }
      })
  }
  private func changeFocusIfNeeded(forNewValue newValue: String, atIndex index: Int) {
    guard let focusedField, focusedField == index, !newValue.isEmpty else {
      return
    }

    if index == self.numberOfDigits - 1 {
      self.focusedField = nil

    } else {
      self.focusedField = focusedField + 1
    }
  }
}

private struct OTPDigitField: View {
  @Binding
  var value: String

  @FocusState
  var isFocused: Bool

  var body: some View {
    TextField("", text: $value)
      .textFieldStyle(.plain)
      .focused($isFocused)
      .keyboardType(.decimalPad)
      .multilineTextAlignment(.center)
      .frame(width: 48, height: 65, alignment: .center)
      .background(TextInputBackground(isFocused: isFocused))
      .font(.title)
      .monospacedDigit()
      .lineLimit(1)
      .animation(.default, value: isFocused)
  }
}

#Preview {
  @Previewable @State var otp: String = ""
  OTPInputField(otp: $otp)
}

#Preview("Danger") {
  @Previewable @State var otp: String = "123456"
  OTPInputField(otp: $otp)
    .style(mood: .danger)
}
