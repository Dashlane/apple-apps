import SwiftUI

public struct PasswordDisplayField: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  private let label: String
  private let password: String
  private let copyAction: (@MainActor () -> Void)?

  public init(
    _ label: String,
    password: String,
    copyAction: (@MainActor () -> Void)? = nil
  ) {
    self.label = label
    self.password = password
    self.copyAction = copyAction
  }

  public var body: some View {
    ObfuscatedDisplayField(label) { obfuscated in
      VStack {
        if obfuscated {
          Text(verbatim: String(repeating: "•", count: password.count))
            .monospaced()
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
        } else {
          Text(.passwordAttributedString(from: password, with: dynamicTypeSize))
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
        }
      }
      .animation(.interactiveSpring(duration: 0.3), value: obfuscated)
    } actions: {
      if let copyAction {
        DS.FieldAction.CopyContent(action: copyAction)
      }
    }
  }
}

#Preview {
  List {
    PasswordDisplayField("Password Field", password: "_") {
      print("Copy action triggered.")
    }
  }
}
