import CoreLocalization
import SwiftUI
import UIKit

struct ObfuscatedDisplayFieldFormattedValueContentView<F: AccessibleObfuscatedFormatStyle>: View
where F.FormatInput == String, F.FormatOutput == String {
  private let format: F
  private let value: F.FormatInput

  @State private var isInstalledInViewHierarchy = false

  init(_ value: F.FormatInput, format: F) {
    self.format = format
    self.value = value
  }

  var body: some View {
    Text(verbatim: format.format(value))
      .foregroundStyle(.textInputValue)
      .monospaced()
      .contentTransition(.numericText())
      .animation(.spring, value: format)
      .accessibilityLabel(Text(verbatim: format.accessibilityText(for: value)))
      .onChange(of: format) { _, newFormat in
        guard isInstalledInViewHierarchy else { return }
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(750))) {
          UIAccessibility.post(
            notification: .announcement,
            argument: newFormat.accessibilityText(for: value)
          )
        }
      }
      .onAppear {
        isInstalledInViewHierarchy = true
      }
  }
}

#Preview("Visa") {
  VStack(alignment: .leading, spacing: 32) {
    ObfuscatedDisplayFieldFormattedValueContentView(
      "4005519200000004",
      format: .cardNumber(obfuscated: true)
    )

    ObfuscatedDisplayFieldFormattedValueContentView(
      "4005519200000004",
      format: .cardNumber(obfuscated: false)
    )
  }
}

#Preview("American Express") {
  VStack(alignment: .leading, spacing: 32) {
    ObfuscatedDisplayFieldFormattedValueContentView(
      "371449635398431",
      format: .cardNumber(obfuscated: true)
    )

    ObfuscatedDisplayFieldFormattedValueContentView(
      "371449635398431",
      format: .cardNumber(obfuscated: false)
    )
  }
}

#Preview("China UnionPay") {
  VStack(alignment: .leading, spacing: 32) {
    ObfuscatedDisplayFieldFormattedValueContentView(
      "6255883202853733",
      format: .cardNumber(obfuscated: true)
    )

    ObfuscatedDisplayFieldFormattedValueContentView(
      "6255883202853733",
      format: .cardNumber(obfuscated: false)
    )
  }
}

#Preview("JCB") {
  VStack(alignment: .leading, spacing: 32) {
    ObfuscatedDisplayFieldFormattedValueContentView(
      "3532014165774870",
      format: .cardNumber(obfuscated: true)
    )

    ObfuscatedDisplayFieldFormattedValueContentView(
      "3532014165774870",
      format: .cardNumber(obfuscated: false)
    )
  }
}

#Preview("Maestro") {
  VStack(alignment: .leading, spacing: 32) {
    ObfuscatedDisplayFieldFormattedValueContentView(
      "6304000000000000",
      format: .cardNumber(obfuscated: true)
    )

    ObfuscatedDisplayFieldFormattedValueContentView(
      "6304000000000000",
      format: .cardNumber(obfuscated: false)
    )
  }
}

#Preview("MasterCard") {
  VStack(alignment: .leading, spacing: 32) {
    ObfuscatedDisplayFieldFormattedValueContentView(
      "5401082051353896",
      format: .cardNumber(obfuscated: true)
    )

    ObfuscatedDisplayFieldFormattedValueContentView(
      "5401082051353896",
      format: .cardNumber(obfuscated: false)
    )
  }
}
#Preview("UATP") {
  VStack(alignment: .leading, spacing: 32) {
    ObfuscatedDisplayFieldFormattedValueContentView(
      "140680888802410",
      format: .cardNumber(obfuscated: true)
    )

    ObfuscatedDisplayFieldFormattedValueContentView(
      "140680888802410",
      format: .cardNumber(obfuscated: false)
    )
  }
}
#Preview("Diners Club") {
  VStack(alignment: .leading, spacing: 32) {
    ObfuscatedDisplayFieldFormattedValueContentView(
      "38600950887409",
      format: .cardNumber(obfuscated: true)
    )

    ObfuscatedDisplayFieldFormattedValueContentView(
      "38600950887409",
      format: .cardNumber(obfuscated: false)
    )
  }
}
