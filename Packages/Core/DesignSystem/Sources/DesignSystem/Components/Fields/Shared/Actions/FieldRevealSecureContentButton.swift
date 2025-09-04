import CoreLocalization
import SwiftUI

struct FieldRevealSecureContentButton: View {
  @Environment(\.textFieldOnRevealSecureValueAction) private var revealSecureValueAction
  private let reveal: Binding<Bool>

  init(reveal: Binding<Bool>) {
    self.reveal = reveal
  }

  var body: some View {
    Button(
      action: {
        withAnimation {
          reveal.wrappedValue.toggle()
        }
        if reveal.wrappedValue {
          revealSecureValueAction?()
        }
      },
      label: {
        Label {
          Text(reveal.wrappedValue ? CoreL10n.kwHide : CoreL10n.kwReveal)
        } icon: {
          revealIcon
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
      }
    )
    .accessibilityLabel(reveal.wrappedValue ? CoreL10n.kwHide : CoreL10n.kwReveal)
  }

  private var revealIcon: Image {
    if reveal.wrappedValue {
      .ds.action.hide.outlined
    } else {
      .ds.action.reveal.outlined
    }
  }
}

private struct PreviewContent: View {
  @State private var revealSecureContent = false

  var body: some View {
    VStack {
      FieldRevealSecureContentButton(reveal: $revealSecureContent)
        .background(.red.opacity(0.2))
      Text("reveals: \(String(describing: revealSecureContent))")
    }
  }
}

#Preview {
  PreviewContent()
}
