#if canImport(UIKit)
  import SwiftUI
  import UIDelight
  import DesignSystem
  import UIComponents

  public struct FeedbackView<Accessory: View>: View {

    public enum Kind {
      case error
      case message
      case twoFA

      var image: Image {
        switch self {
        case .error:
          return Image(asset: Asset.error)
        case .message:
          return Image(asset: Asset.shield)
        case .twoFA:
          return Image(asset: Asset.authenticator)
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
          .navigationBarStyle(.transparent)
          .navigationBarBackButtonHidden(hideBackButton)
          .toolbar(.hidden, for: .navigationBar)
      }
      .backgroundColorIgnoringSafeArea(.ds.background.alternate)
      .overlay(overlayButton)
      .loginAppearance()
    }

    var mainView: some View {
      HStack {
        VStack(alignment: .leading, spacing: 16) {
          type.image
            .foregroundColor(type.color)
            .padding(.horizontal, 16)
            .padding(.bottom, 41)
          Text(title)
            .textStyle(.title.section.large)
            .foregroundStyle(Color.ds.text.neutral.catchy)
          Text(message)
            .textStyle(.body.standard.regular)
            .foregroundStyle(Color.ds.text.neutral.standard)
          accessory
          if let helpCTA = helpCTA {
            Link(
              title: helpCTA.title,
              url: helpCTA.urlToOpen)
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
        Button(primaryButton.title, action: primaryButton.action)

        if let secondaryButton = secondaryButton {
          Button(secondaryButton.title, action: secondaryButton.action)
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
#endif
