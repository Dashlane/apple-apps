import CoreLocalization
import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIDelight

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
      NativeAlert(spacing: 0) {
        Text(CoreL10n.kwDeviceRenameTitle)
          .font(.headline)
          .padding()
        DS.TextField(CoreL10n.kwDeviceRenamePlaceholder, text: $name)
          .onSubmit(completionFromKeyboard)
          .submitLabel(.done)
          .textContentType(.oneTimeCode)
          .focused($isTextFieldFocused)
          .padding()
      } buttons: {
        Button(CoreL10n.cancel, role: .cancel, action: dismiss)

        Button(CoreL10n.kwConfirmButton) {
          self.completion(.updated(name))
        }
        .disabled(name.isEmpty)
      }
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
