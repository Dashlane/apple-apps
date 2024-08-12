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
    .backgroundColorIgnoringSafeArea(Color.ds.background.default)
  }

  @ViewBuilder
  private var content: some View {
    if let newPaywallContent = NewPaywallContent(trigger: model.trigger) {
      NewPaywallContentView(content: newPaywallContent)
    } else if let oldContent = model.trigger.oldContent {
      defaultContent(oldContent)
    }
  }

  @ViewBuilder
  private func defaultContent(_ content: PaywallViewModel.OldPaywallContent) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      content.image.swiftUIImage
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 84, height: 84)
        .animation(nil, value: content.image.name)
        .foregroundColor(.ds.text.neutral.standard)

      Text(content.title)
        .foregroundColor(.ds.text.neutral.catchy)
        .textStyle(.title.section.large)

      Text(content.text)
        .foregroundColor(.ds.text.neutral.standard)
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

        Button(L10n.Core.paywallsPlanOptionsCTA, action: { action(.displayList) })
          .style(mood: .brand, intensity: .quiet)

      } else {
        Button(L10n.Core.paywallsPlanOptionsCTA, action: { action(.displayList) })
          .style(mood: .brand, intensity: .catchy)
      }
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(.bottom, 16)
  }

  private var closeButton: some View {
    NavigationBarButton(action: { action(.cancel) }, label: { Text(L10n.Core.kwButtonClose) })
  }
}

struct PaywallView_Previews: PreviewProvider {
  static let previewedCapabilities: [CapabilityKey] = [
    .secureNotes,
    .securityBreach,
    .sharingLimit,
    .secureWiFi,
  ]

  static var previews: some View {
    ForEach(previewedCapabilities, id: \.rawValue) { capability in
      MultiContextPreview {
        PaywallViewModel(
          .capability(key: capability), purchasePlanGroup: PurchasePlanRowView_Previews.planTier
        ).map { PaywallView(model: $0, shouldDisplayCloseButton: false, action: { _ in }) }
          .background(.ds.background.default)
      }
    }
    MultiContextPreview {
      PaywallViewModel(.capability(key: .secureNotes), purchasePlanGroup: nil).map {
        PaywallView(model: $0, shouldDisplayCloseButton: false, action: { _ in })
      }
      .background(.ds.background.default)
    }

    MultiContextPreview {
      PaywallViewModel(.frozenAccount(firstAnnouncement: false), purchasePlanGroup: nil).map {
        PaywallView(model: $0, shouldDisplayCloseButton: false, action: { _ in })
      }
      .background(.ds.background.default)
    }
  }
}
