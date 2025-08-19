import CoreLocalization
import DesignSystem
import SwiftUI
import TOTPGenerator
import UIComponents

public struct GeneratedOTPCodeRowView: View {

  @StateObject
  var model: GeneratedOTPCodeRowViewModel

  let performAction: (BasicTokenRowAction) -> Void

  let isEditing: Bool
  let codeFont: Font
  let hidesLeadingAction: Bool

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  public init(
    model: @autoclosure @escaping () -> GeneratedOTPCodeRowViewModel,
    isEditing: Bool,
    hidesLeadingAction: Bool = false,
    performAction: @escaping (BasicTokenRowAction) -> Void
  ) {
    self._model = .init(wrappedValue: model())
    self.isEditing = isEditing
    self.performAction = performAction
    self.codeFont = isEditing ? .title3 : .largeTitle
    self.hidesLeadingAction = hidesLeadingAction
  }

  public var body: some View {
    Group {
      ZStack {
        leadingAction
      }
      ZStack {
        Button(
          action: {
            performAction(.copy(model.code, token: model.token))
          },
          label: {
            Text(model.separatedCode)
              .font(codeFont)
              .bold()
              .monospacedDigit()
              .foregroundStyle(Color.ds.text.neutral.catchy)
          }
        )
        .id(model.code)
        .transition(
          AnyTransition.asymmetric(
            insertion: .move(edge: .top),
            removal: .move(edge: .bottom)
          ).combined(with: .opacity)
        )
        .accessibilityIdentifier("Code")
        .accessibilityElement()
        .fiberAccessibilityLabel(Text(model.accessibilityCode))
      }
      .animation(.default, value: model.code)
      Button(
        action: {
          if isEditing {
            performAction(.delete(model.token))
          } else {
            performAction(.copy(model.code, token: model.token))
          }
        },
        label: {
          copyTrashButtonImage
            .resizable()
            .accessibilityLabel(isEditing ? CoreL10n.kwDelete : CoreL10n.kwCopy)
            .scaledToFit()
            .frame(height: 24)
            .foregroundStyle(Color.ds.text.neutral.standard)
        })
    }
  }

  @ViewBuilder
  var leadingAction: some View {
    switch model.currentMode {
    case let .totp(progress, period):
      ProgressView(value: progress)
        .progressViewStyle(.countdown)
        .onReceive(timer) { _ in
          model.update(period: period)
        }
        .accessibilityHidden(true)
        .animation(.linear(duration: 1), value: progress)
        .controlSize(.large)
        .id(model.code)

    case .hotp:
      if !hidesLeadingAction {
        Button(
          action: {
            model.increaseHOTPCounter()
          },
          label: {
            Image.ds.action.refresh.outlined
              .foregroundStyle(Color.ds.text.brand.standard)
          }
        )
        .fiberAccessibilityLabel(Text(CoreL10n.kwPadExtensionGeneratorRefresh))
      }
    }
  }

  private var copyTrashButtonImage: Image {
    return isEditing ? Image.ds.action.delete.outlined : Image.ds.action.copy.outlined
  }
}

struct GeneratedOTPCodeRowView_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      GeneratedOTPCodeRowView(
        model: GeneratedOTPCodeRowViewModel(
          token: OTPInfo.mock, databaseService: AuthenticatorDatabaseServiceMock()),
        isEditing: false, performAction: { _ in })
      GeneratedOTPCodeRowView(
        model: GeneratedOTPCodeRowViewModel(
          token: OTPInfo.mock, databaseService: AuthenticatorDatabaseServiceMock()),
        isEditing: true, performAction: { _ in })
    }
    .previewLayout(.sizeThatFits)
  }
}
