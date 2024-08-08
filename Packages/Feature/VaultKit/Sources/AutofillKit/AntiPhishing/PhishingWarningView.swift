import CoreLocalization
import DesignSystem
import SwiftUI

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
              Button(
                action: {
                  dismiss()
                }, title: L10n.Core.cancel
              )
              .foregroundStyle(Color.ds.text.brand.standard)
            })
        })
        .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }

  }

  @ViewBuilder
  var main: some View {
    VStack(spacing: 16) {
      intro
      websites
        .frame(maxHeight: .infinity, alignment: .top)
      buttons
    }
    .padding([.horizontal, .top], 24)
  }

  @ViewBuilder
  var intro: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(L10n.Core.AntiPhishing.Intro.title)
        .textStyle(.title.section.medium)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(L10n.Core.AntiPhishing.Intro.description)
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
          L10n.Core.AntiPhishing.Websites.trusted,
          text: .constant(viewModel.credential.trustedWebsite ?? "")
        )
        .style(mood: .positive)

        DS.TextField(
          L10n.Core.AntiPhishing.Websites.current,
          text: .constant(viewModel.visitedWebsite)
        )
        .style(mood: .warning)
      }
    )
    .editionDisabled(true, appearance: .discrete)

  }

  @ViewBuilder
  var buttons: some View {
    VStack(spacing: 8) {
      Button(L10n.Core.AntiPhishing.Actions.doNotTrust) {
        viewModel.doNotTrustWebsite()
      }
      .buttonStyle(.designSystem(.titleOnly))

      Button(L10n.Core.AntiPhishing.Actions.trust) {
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
