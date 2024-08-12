#if canImport(UIKit)
  import SwiftUI
  import UIDelight
  import CoreLocalization

  public struct DeviceRenameView: View {
    public enum Completion {
      case updated(String)
      case cancel
    }
    let completion: (Completion) -> Void

    @State
    var name: String = ""

    @FocusState
    var isTextFieldFocused: Bool

    public init(name: String, completion: @escaping (Completion) -> Void) {
      self._name = State(initialValue: name)
      self.completion = completion
    }

    public var body: some View {
      ZStack {
        backgroundView
        VStack(spacing: 0) {
          Text(L10n.Core.kwDeviceRenameTitle)
            .font(.headline)
            .padding()
          TextField(L10n.Core.kwDeviceRenamePlaceholder, text: $name)
            .onSubmit(completionFromKeyboard)
            .submitLabel(.done)
            .textContentType(.oneTimeCode)
            .focused($isTextFieldFocused)
            .padding()
          Divider()
          HStack {
            Button(L10n.Core.cancel, action: dismiss)
              .buttonStyle(AlertButtonStyle())
            Divider()
            Button(L10n.Core.kwConfirmButton) {
              self.completion(.updated(name))
            }
            .disabled(name.isEmpty)
            .buttonStyle(AlertButtonStyle())
          }
          .fixedSize(horizontal: false, vertical: true)
        }
        .modifier(AlertStyle())
      }
      .onAppear {
        self.isTextFieldFocused = true
      }
    }

    private var backgroundView: some View {
      Color.black.opacity(0.5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }

    private func dismiss() {
      self.completion(.cancel)
    }

    private func completionFromKeyboard() {
      if name.isEmpty {
        dismiss()
      } else {
        self.completion(.updated(name))
      }
    }
  }

  struct DeviceRenameView_Previews: PreviewProvider {
    static var previews: some View {
      DeviceRenameView(name: "Hello") { _ in

      }
    }
  }
#endif
