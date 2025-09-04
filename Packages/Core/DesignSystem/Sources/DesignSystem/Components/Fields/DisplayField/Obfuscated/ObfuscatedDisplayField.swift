import SwiftTreats
import SwiftUI

public struct ObfuscatedDisplayField<Content: View, Actions: View>: View {
  @Environment(\.defaultFieldActionsHidden) private var defaultFieldActionsHidden

  @State private var isRevealed = false

  private let actions: Actions
  private let contentProvider: (Bool) -> Content
  private let label: String

  public init(
    _ label: String,
    @ViewBuilder content: @escaping (Bool) -> Content,
    @ViewBuilder actions: @escaping () -> Actions
  ) {
    self.actions = actions()
    self.contentProvider = content
    self.label = label
  }

  public init(
    _ label: String,
    value: String,
    format: FieldValueFormat,
    @ViewBuilder actions: @escaping () -> Actions
  ) where Content == ObfuscatedDisplayFieldFormattedContentView {
    self.actions = actions()
    self.contentProvider = { obfuscated in
      ObfuscatedDisplayFieldFormattedContentView(
        value: value,
        format: format,
        obfuscated: obfuscated
      )
    }
    self.label = label
  }

  public var body: some View {
    DisplayField(label) {
      contentProvider(!isRevealed)
    } actions: {
      if !defaultFieldActionsHidden {
        DS.FieldAction.RevealSecureContent(reveal: $isRevealed)
      }
      actions
    }
  }
}

public struct ObfuscatedDisplayFieldFormattedContentView: View {
  private let format: FieldValueFormat
  private let obfuscated: Bool
  private let value: String

  init(value: String, format: FieldValueFormat, obfuscated: Bool) {
    self.format = format
    self.obfuscated = obfuscated
    self.value = value
  }

  public var body: some View {
    switch format {
    case .accountIdentifier(let identifier):
      switch identifier {
      case .bic:
        ObfuscatedDisplayFieldFormattedValueContentView(
          value,
          format: .bic(obfuscated: obfuscated)
        )
      case .iban:
        ObfuscatedDisplayFieldFormattedValueContentView(
          value,
          format: .iban(obfuscated: obfuscated)
        )
      }
    case .cardNumber:
      ObfuscatedDisplayFieldFormattedValueContentView(
        value,
        format: .cardNumber(obfuscated: obfuscated)
      )
    case let .obfuscated(maxLength):
      ObfuscatedDisplayFieldFormattedValueContentView(
        value,
        format: .obfuscated(obfuscated: obfuscated, maxLength: maxLength)
      )
    }
  }
}

private struct CustomPreviewContent: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    List {
      ObfuscatedDisplayField("Obfuscated Data") { obfuscated in
        if obfuscated {
          Text("••••••••••")
            .monospaced()
        } else {
          Text(
            AttributedString.passwordAttributedString(
              from: "_",
              with: dynamicTypeSize
            )
          )
        }
      } actions: {
        DS.FieldAction.CopyContent {
        }
      }
    }
  }
}

#Preview("Custom") {
  CustomPreviewContent()
}

#Preview("Card Number") {
  List {
    ObfuscatedDisplayField(
      "Card Number [VISA]",
      value: "4020022517630895",
      format: .cardNumber
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Card Number [American Express]",
      value: "346448926749551",
      format: .cardNumber
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Card Number [China UnionPay]",
      value: "6255883202853733",
      format: .cardNumber
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Card Number [UATP]",
      value: "140680888802410",
      format: .cardNumber
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Card Number [Maestro]",
      value: "5893781850014634",
      format: .cardNumber
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Card Number [MasterCard]",
      value: "5401082051353896",
      format: .cardNumber
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Card Number [Diners Club]",
      value: "38600950887409",
      format: .cardNumber
    ) {
      DS.FieldAction.CopyContent {
      }
    }
  }
}

#Preview("IBAN") {
  List {
    ObfuscatedDisplayField(
      "France",
      value: "FR5612739000707416692922C51",
      format: .accountIdentifier(.iban)
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Andorra",
      value: "AD1733777699898122378234",
      format: .accountIdentifier(.iban)
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Azerbaijan",
      value: "AZ33XCYD81163912811538381835",
      format: .accountIdentifier(.iban)
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Belgium",
      value: "BE68549222432734",
      format: .accountIdentifier(.iban)
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Finland",
      value: "FI1495259174391621",
      format: .accountIdentifier(.iban)
    ) {
      DS.FieldAction.CopyContent {
      }
    }
  }
}

#Preview("BIC") {
  List {
    ObfuscatedDisplayField(
      "French BIC (AXA Bank)",
      value: "AXABFRPP",
      format: .accountIdentifier(.bic)
    ) {
      DS.FieldAction.CopyContent {
      }
    }
    ObfuscatedDisplayField(
      "Irish BIC (HSBC Bank)",
      value: "HSBCIE2D",
      format: .accountIdentifier(.bic)
    ) {
      DS.FieldAction.CopyContent {
      }
    }
  }
}

#Preview("Regular") {
  List {
    ObfuscatedDisplayField(
      "Generated password",
      value: "_",
      format: .obfuscated()
    ) {
      DS.FieldAction.CopyContent {
      }
    }

    ObfuscatedDisplayField(
      "Generated password",
      value: "MyStrongPassword123###",
      format: .obfuscated(maxLength: 17)
    ) {
      DS.FieldAction.CopyContent {
      }
    }

    ObfuscatedDisplayField(
      "Note",
      value: "Test note",
      format: .obfuscated(maxLength: 4)
    ) {
      DS.FieldAction.CopyContent {
      }
    }
  }
}
