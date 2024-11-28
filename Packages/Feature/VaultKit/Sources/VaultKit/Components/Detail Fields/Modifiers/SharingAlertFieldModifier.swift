import CoreLocalization
import CorePersonalData
import DashTypes
import DesignSystem
import SwiftUI
import UIComponents

public struct LimitedRightsModifierViewModel {
  let hasInfoButton: Bool
  let item: PersonalDataCodable
  let isFrozen: Bool

  var shouldLimit: Bool {
    return (item.isShared && item.metadata.sharingPermission == .limited) || isFrozen
  }

  public init(item: PersonalDataCodable, isFrozen: Bool, hasInfoButton: Bool = true) {
    self.hasInfoButton = hasInfoButton
    self.item = item
    self.isFrozen = isFrozen
  }
}

extension View {
  @ViewBuilder
  public func limitedRights(
    hasInfoButton: Bool = true,
    item: PersonalDataCodable
  ) -> some View {
    if item.isShared && item.metadata.sharingPermission == .limited,
      let sharingType = item.metadata.contentType.sharingType
    {
      self.modifier(
        SharingAlertFieldModifier(sharingType: sharingType, hasInfoButton: hasInfoButton))
    } else {
      self
    }
  }

  @ViewBuilder
  public func limitedRights(model: LimitedRightsModifierViewModel) -> some View {
    if model.shouldLimit, let sharingType = model.item.metadata.contentType.sharingType {
      self.modifier(
        SharingAlertFieldModifier(sharingType: sharingType, hasInfoButton: model.hasInfoButton))
    } else {
      self
    }
  }
}

private struct SharingAlertFieldModifier: ViewModifier {

  @State
  var showAlert: Bool = false

  @Environment(\.detailMode)
  var detailMode

  let sharingType: SharingType
  let hasInfoButton: Bool

  @ViewBuilder
  func body(content: Content) -> some View {
    HStack {
      content
        .environment(\.detailMode, .limitedViewing)
        .editionDisabled(true, appearance: .discrete)
        .textInputRemoveBuiltInActions(true)
      if hasInfoButton {
        Image.ds.feedback.info.outlined
          .foregroundColor(.ds.text.brand.standard)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
    .highPriorityGesture(
      TapGesture()
        .onEnded { _ in
          self.showAlert = true
        }
    )
    .alert(
      sharingType.limitedRightsAlertTitle,
      isPresented: $showAlert,
      actions: {
        Button(L10n.Core.kwButtonOk) {}
      }
    )
  }
}

extension SharingType {
  public var limitedRightsAlertTitle: String {
    switch self {
    case .password:
      return CoreLocalization.L10n.Core.kwLimitedRightMessage
    case .note:
      return CoreLocalization.L10n.Core.kwSecureNoteLimitedRightMessage
    case .secret:
      return CoreLocalization.L10n.Core.Secrets.Sharing.limitedRightsMessage
    }
  }
}
