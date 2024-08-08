#if canImport(UIKit)

  import SwiftUI
  import UIKit
  import DesignSystem

  private struct PasswordFieldSecureKey: EnvironmentKey {
    static let defaultValue: Bool = true
  }

  private struct PasswordFieldMonospacedFont: EnvironmentKey {
    static let defaultValue: Bool = false
  }

  extension EnvironmentValues {
    fileprivate var isSecure: Bool {
      get { self[PasswordFieldSecureKey.self] }
      set { self[PasswordFieldSecureKey.self] = newValue }
    }

    fileprivate var monospacedFont: Bool {
      get { self[PasswordFieldMonospacedFont.self] }
      set { self[PasswordFieldMonospacedFont.self] = newValue }
    }
  }

  public struct PasswordField: View {

    private enum Field {
      case secure
      case plain
    }

    @Environment(\.isSecure) var secureTextEntry
    @Environment(\.monospacedFont) var monospacedFont

    private let placeholder: LocalizedStringKey
    private let text: Binding<String>
    private let onSubmit: (() -> Void)?

    private let isFocused: Binding<Bool>
    @FocusState private var focusedField: Field?

    public init(
      _ placeholder: LocalizedStringKey, text: Binding<String>,
      isFocused: Binding<Bool> = .constant(false), onSubmit: (() -> Void)? = nil
    ) {
      self.placeholder = placeholder
      self.text = text
      self.isFocused = isFocused
      self.onSubmit = onSubmit
    }

    public init(
      _ placeholder: String, text: Binding<String>, isFocused: Binding<Bool> = .constant(false),
      onSubmit: (() -> Void)? = nil
    ) {
      self.init(
        LocalizedStringKey(placeholder), text: text, isFocused: isFocused, onSubmit: onSubmit)
    }

    public var body: some View {
      ZStack {
        Group {
          SecureField(placeholder, text: text)
            .focused($focusedField, equals: .secure)
            .opacity(secureTextEntry ? 1 : 0)
          TextField(placeholder, text: text)
            .focused($focusedField, equals: .plain)
            .opacity(!secureTextEntry ? 1 : 0)
        }
        .font(Font.system(.body, design: monospacedFont ? .monospaced : .default))
        .onSubmit {
          onSubmit?()
        }
      }
      .onChange(
        of: isFocused.wrappedValue,
        perform: { focus in
          if focus {
            focusedField = secureTextEntry ? .secure : .plain
          } else {
            focusedField = nil
          }
        }
      )
      .onChange(
        of: focusedField,
        perform: { focusedField in
          isFocused.wrappedValue = focusedField != nil
        }
      )
      .onChange(of: secureTextEntry) { _ in
        guard isFocused.wrappedValue else { return }
        focusedField = secureTextEntry ? .secure : .plain
      }
      .onAppear {
        guard isFocused.wrappedValue else { return }
        focusedField = secureTextEntry ? .secure : .plain
      }
    }
  }

  extension View {

    public func passwordFieldSecure(_ isSecure: Bool) -> some View {
      environment(\.isSecure, isSecure)
    }

    public func passwordFieldMonospacedFont(_ useMonospacedFont: Bool) -> some View {
      environment(\.monospacedFont, useMonospacedFont)
    }
  }

  struct PasswordField_Previews: PreviewProvider {

    struct Preview: View {
      @State
      private var isFocused: Bool = true

      @State
      private var isSecure = true

      @State
      var text: String

      var body: some View {
        NavigationView {
          VStack {
            PasswordField("Placeholder", text: $text, isFocused: $isFocused)
              .passwordFieldSecure(isSecure)
              .submitLabel(.search)
              .passwordFieldMonospacedFont(true)
              .textInputAutocapitalization(.words)
              .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                  Button("Keyboard Accessory") {}
                }
              }

            Button("Reveal", action: { isSecure.toggle() })
          }
          .padding()
        }
      }
    }

    static var previews: some View {
      Preview(text: "Hello World")
    }
  }

#endif
