import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIComponents
import UIDelight

public struct FeedbackView<Accessory: View>: View {

  public enum Kind {
    case error
    case message
    case twoFA

    var image: Image {
      switch self {
      case .error:
        return .ds.feedback.fail.outlined
      case .message:
        return .ds.feedback.success.outlined
      case .twoFA:
        return .ds.feature.authenticator.outlined
      }
    }

    var color: Color {
      switch self {
      case .error:
        return .ds.text.danger.quiet
      default:
        return .ds.text.brand.quiet
      }
    }
  }

  let title: String
  let message: String
  let accessory: Accessory
  let type: Kind
  let hideBackButton: Bool
  let helpCTA: (title: String, urlToOpen: URL)?
  let primaryButton: (title: String, action: () -> Void)
  let secondaryButton: (title: String, action: () -> Void)?

  public init(
    title: String,
    message: String,
    kind: Kind = .error,
    hideBackButton: Bool = true,
    helpCTA: (title: String, urlToOpen: URL)? = nil,
    primaryButton: (title: String, action: () -> Void),
    secondaryButton: (title: String, action: () -> Void)? = nil,
    @ViewBuilder accessory: () -> Accessory = { EmptyView() }
  ) {
    self.title = title
    self.message = message
    self.accessory = accessory()
    self.type = kind
    self.hideBackButton = hideBackButton
    self.helpCTA = helpCTA
    self.primaryButton = primaryButton
    self.secondaryButton = secondaryButton
  }

  public var body: some View {
    ScrollView {
      mainView
        .navigationBarBackButtonHidden(hideBackButton)
        .toolbar(.hidden, for: .navigationBar)
    }
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .overlay(overlayButton)
    .loginAppearance()
  }

  var mainView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 16) {
        type.image
          .resizable()
          .foregroundStyle(type.color)
          .frame(width: 62, height: 62)
          .padding(.horizontal, 16)
          .padding(.bottom, 41)
        Text(title)
          .textStyle(.title.section.large)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        Text(message)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        accessory
        if let helpCTA = helpCTA {
          SheetLink(helpCTA.title, url: helpCTA.urlToOpen)
        }
      }
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding(.all, 24)
  }

  var overlayButton: some View {
    VStack(spacing: 8) {
      Spacer()
      Button(
        action: {
          primaryButton.action()
        },
        label: {
          Text(primaryButton.title)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
        })

      if let secondaryButton = secondaryButton {
        Button(
          action: {
            secondaryButton.action()
          },
          label: {
            Text(secondaryButton.title)
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity)
          }
        )
        .style(mood: .brand, intensity: .quiet)
      }
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(.horizontal, 24)
    .padding(.bottom, 24)
  }
}

#Preview {
  NavigationView {
    FeedbackView(
      title: "Title",
      message: "Message",
      hideBackButton: true,
      helpCTA: ("Cta", URL(string: "google.com")!),
      primaryButton: ("Try again", {}),
      secondaryButton: ("Cancel", {})
    )
  }
}
