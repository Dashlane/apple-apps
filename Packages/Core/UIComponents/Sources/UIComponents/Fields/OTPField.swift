#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import Combine
  import DesignSystem

  public struct OTPField: View {
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
            .onChange(of: binding.wrappedValue) { newValue in
              changeFocusIfNeeded(forNewValue: newValue, atIndex: index)
            }
            .onChange(of: focusedField) { focusedField in
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

  extension View {
    public func otpFieldStyle(
      backgroundColor: Color = .ds.container.agnostic.neutral.quiet,
      focusColor: Color = .ds.border.brand.standard.active,
      strokeColor: Color? = nil
    ) -> some View {

      self.environment(
        \.otpFieldStyle,
        .init(
          backgroundColor: backgroundColor,
          focusColor: focusColor,
          strokeColor: strokeColor))
    }
  }

  private struct OTPDigitFieldStyle {
    let backgroundColor: Color
    let focusColor: Color

    let strokeColor: Color?
  }

  extension EnvironmentValues {
    fileprivate var otpFieldStyle: OTPDigitFieldStyle {
      get {
        return self[OTPDigitStyleEnvironmentKey.self]
      }
      set {
        self[OTPDigitStyleEnvironmentKey.self] = newValue
      }
    }
  }

  private struct OTPDigitStyleEnvironmentKey: EnvironmentKey {
    typealias Value = OTPDigitFieldStyle
    static var defaultValue: OTPDigitFieldStyle = .init(
      backgroundColor: .ds.container.agnostic.neutral.quiet,
      focusColor: .ds.border.brand.standard.active,
      strokeColor: nil)
  }

  private struct OTPDigitField: View {
    @Binding
    var value: String

    @Environment(\.otpFieldStyle)
    var style

    @FocusState
    var isFocused: Bool

    var body: some View {
      TextField("", text: $value)
        .textFieldStyle(.plain)
        .focused($isFocused)
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.center)
        .frame(width: 48, height: 65, alignment: .center)
        .background(
          ContainerRelativeShape().fill(style.backgroundColor)
        )
        .overlay {
          if isFocused {
            ContainerRelativeShape().inset(by: 1).stroke(style.focusColor, lineWidth: 2)
          } else if let strokeColor = style.strokeColor {
            ContainerRelativeShape().inset(by: 0.5).stroke(strokeColor, lineWidth: 1)
          }
        }
        .containerShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .font(.title)
        .monospacedDigit()
        .lineLimit(1)
        .tint(style.focusColor)
        .animation(.default, value: isFocused)
        .animation(.default, value: style.strokeColor)
    }
  }

  struct OTPField_Previews: PreviewProvider {
    struct TestView: View {
      @State
      var otp: String = ""

      @State
      var hasStroke: Bool = false

      var body: some View {
        VStack {
          OTPField(otp: $otp)
            .otpFieldStyle(strokeColor: hasStroke ? .ds.border.danger.standard.active : nil)
          Button("Clear") {
            otp = ""
          }

          Toggle("Toggle stroke", isOn: $hasStroke)
            .padding()

        }
        .tint(.ds.text.brand.standard)
      }
    }

    static var previews: some View {
      TestView()
      TestView()
        .otpFieldStyle(backgroundColor: .red, strokeColor: .blue)
        .previewDisplayName("custom style")

    }
  }

#endif
