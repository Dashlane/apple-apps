import Combine
import CoreLocalization
import CorePremium
import DesignSystem
import SwiftUI
import UIComponents
import UIDelight

public struct PaywallView: View {

  public enum Action {
    case displayList
    case planDetails(PlanTier)
    case cancel
  }

  let model: PaywallViewModel
  let shouldDisplayCloseButton: Bool

  let action: (Action) -> Void

  public init(
    model: PaywallViewModel,
    shouldDisplayCloseButton: Bool,
    action: @escaping (Action) -> Void
  ) {
    self.model = model
    self.shouldDisplayCloseButton = shouldDisplayCloseButton
    self.action = action
  }

  public var body: some View {
    VStack(alignment: .leading) {
      ViewThatFits(in: .vertical) {
        VStack {
          Spacer()
          content
          Spacer()
        }

        ScrollView {
          content
        }
      }
      CTAs
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        if shouldDisplayCloseButton {
          closeButton
        }
      }
    }
    .padding(.horizontal, 24)
    .reportPageAppearance(model.page)
    .background(Color.ds.background.default, ignoresSafeAreaEdges: .all)
  }

  @ViewBuilder
  private var content: some View {
    if let newPaywallContent = NewPaywallContent(
      capability: model.capability, premiumStatusProvider: model.statusProvider)
    {
      NewPaywallContentView(content: newPaywallContent)
    } else if let oldContent = model.oldContent {
      defaultContent(oldContent)
    }
  }

  @ViewBuilder
  private func defaultContent(_ content: PaywallViewModel.OldPaywallContent) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      content.image
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 84, height: 84)
        .animation(nil, value: content.image)
        .foregroundStyle(Color.ds.text.neutral.standard)

      Text(content.title)
        .foregroundStyle(Color.ds.text.neutral.catchy)
        .textStyle(.title.section.large)

      Text(content.text)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .font(.system(size: 17))
        .fontWeight(.regular)
    }
  }

  @ViewBuilder
  private var CTAs: some View {
    VStack(alignment: .center, spacing: 6) {
      if let upgradeText = model.upgradeText, let planGroup = model.purchasePlanGroup {
        Button(upgradeText, action: { action(.planDetails(planGroup)) })
          .style(mood: .brand, intensity: .catchy)

        Button(CoreL10n.paywallsPlanOptionsCTA, action: { action(.displayList) })
          .style(mood: .brand, intensity: .quiet)

      } else {
        Button(CoreL10n.paywallsPlanOptionsCTA, action: { action(.displayList) })
          .style(mood: .brand, intensity: .catchy)
      }
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(.bottom, 16)
  }

  private var closeButton: some View {
    Button(action: { action(.cancel) }, label: { Text(CoreL10n.kwButtonClose) })
  }
}

#if DEBUG

  private struct PaywallPreviewWrapper: View {
    let capability: CapabilityKey
    let purchasePlanGroup: PlanTier?

    var body: some View {
      if let viewModel = PaywallViewModel(
        capability: capability, purchasePlanGroup: purchasePlanGroup, statusProvider: .mock())
      {
        PaywallView(model: viewModel, shouldDisplayCloseButton: false, action: { _ in })
          .background(.ds.background.default)
      } else {
        Text("Failed to create PaywallViewModel")
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .background(.ds.background.default)
      }
    }
  }

  #Preview("Secure Notes") {
    PaywallPreviewWrapper(
      capability: .secureNotes, purchasePlanGroup: PlanPreviewUtilities.planTier(kind: .advanced))
  }

  #Preview("Security Breach") {
    PaywallPreviewWrapper(
      capability: .securityBreach, purchasePlanGroup: PlanPreviewUtilities.planTier(kind: .advanced)
    )
  }

  #Preview("Sharing Limit") {
    PaywallPreviewWrapper(
      capability: .sharingLimit, purchasePlanGroup: PlanPreviewUtilities.planTier(kind: .advanced))
  }

  #Preview("Secure WiFi") {
    PaywallPreviewWrapper(
      capability: .secureWiFi, purchasePlanGroup: PlanPreviewUtilities.planTier(kind: .advanced))
  }

  #Preview("Secure Notes - No Plan Group") {
    PaywallPreviewWrapper(capability: .secureNotes, purchasePlanGroup: nil)
  }
#endif
