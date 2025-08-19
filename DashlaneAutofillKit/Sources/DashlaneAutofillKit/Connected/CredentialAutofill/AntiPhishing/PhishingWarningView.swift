import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UserTrackingFoundation

@MainActor
public struct PhishingWarningView: View {

  let viewModel: PhishingWarningViewModel

  @Environment(\.dismiss)
  var dismiss

  public init(viewModel: PhishingWarningViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    NavigationStack {
      main
        .toolbar(content: {
          ToolbarItem(
            placement: .topBarLeading,
            content: {
              Button(CoreL10n.cancel) {
                dismiss()
              }
              .foregroundStyle(Color.ds.text.brand.standard)
            })
        })
        .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    }
    .reportPageAppearance(.autofillNotificationPhishingPrevention)
  }

  @ViewBuilder
  var main: some View {
    VStack(spacing: 16) {
      intro
      websites
        .frame(maxHeight: .infinity, alignment: .top)
      buttons
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding([.horizontal, .top], 24)
    .padding(.bottom, Device.is(.pad) ? 24 : 0)
  }

  @ViewBuilder
  var intro: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(CoreL10n.AntiPhishing.Intro.title)
        .textStyle(.title.section.medium)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(CoreL10n.AntiPhishing.Intro.description)
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
    }
  }

  @ViewBuilder
  var websites: some View {
    VStack(
      spacing: 18,
      content: {
        DS.TextField(
          CoreL10n.AntiPhishing.Websites.trusted,
          text: .constant(viewModel.credential.trustedWebsite ?? "")
        )
        .style(mood: .positive)

        DS.TextField(
          CoreL10n.AntiPhishing.Websites.current,
          text: .constant(viewModel.visitedWebsite)
        )
        .style(mood: .warning)
      }
    )
    .fieldEditionDisabled(true, appearance: .discrete)

  }

  @ViewBuilder
  var buttons: some View {
    VStack(spacing: 8) {
      Button(CoreL10n.AntiPhishing.Actions.doNotTrust) {
        viewModel.doNotTrustWebsite()
      }
      .buttonStyle(.designSystem(.titleOnly))

      Button(CoreL10n.AntiPhishing.Actions.trust) {
        Task {
          await viewModel.trustWebsite()
        }
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .quiet)
    }
  }
}

#Preview {
  NavigationStack {
    PhishingWarningView(viewModel: .mock())
  }
}
