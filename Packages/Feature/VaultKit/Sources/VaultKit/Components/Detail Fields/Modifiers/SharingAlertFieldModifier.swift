import CoreLocalization
import CorePersonalData
import CoreTypes
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
    item: PersonalDataCodable,
    isFrozen: Bool
  ) -> some View {
    if item.isShared && item.metadata.sharingPermission == .limited,
      let sharingType = item.metadata.contentType.sharingType
    {
      self.modifier(
        SharingAlertFieldModifier(
          sharingType: sharingType, hasInfoButton: hasInfoButton, isFrozen: isFrozen))
    } else {
      self
    }
  }

  @ViewBuilder
  public func limitedRights(model: LimitedRightsModifierViewModel) -> some View {
    if model.shouldLimit, let sharingType = model.item.metadata.contentType.sharingType {
      self.modifier(
        SharingAlertFieldModifier(
          sharingType: sharingType, hasInfoButton: model.hasInfoButton, isFrozen: model.isFrozen))
    } else {
      self
    }
  }

  @ViewBuilder
  public func limitedRightsAutofill(model: LimitedRightsModifierViewModel) -> some View {
    if model.shouldLimit, let sharingType = model.item.metadata.contentType.sharingType {
      self.modifier(
        SharingAlertAutofillFieldModifier(
          sharingType: sharingType, hasInfoButton: model.hasInfoButton, isFrozen: model.isFrozen))
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

  let isFrozen: Bool

  @ViewBuilder
  func body(content: Content) -> some View {
    HStack {
      content
        .environment(\.detailMode, .limitedViewing)
        .fieldEditionDisabled(true, appearance: .discrete)
        .defaultFieldActionsHidden()
      if hasInfoButton {
        Image.ds.feedback.info.outlined
          .foregroundStyle(Color.ds.text.brand.standard)
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
      isFrozen && sharingType == .password
        ? CoreL10n.fozenUserLimitAlertTitle : sharingType.limitedRightsAlertTitle,
      isPresented: $showAlert,
      actions: {
        Button(CoreL10n.kwButtonOk) {}
      },
      message: {
        Text(isFrozen && sharingType == .password ? CoreL10n.fozenUserLimitAlertMessage : "")
      }
    )
  }
}

private struct SharingAlertAutofillFieldModifier: ViewModifier {

  @State
  var showAlert: Bool = false

  @Environment(\.detailMode)
  var detailMode

  let sharingType: SharingType
  let hasInfoButton: Bool

  let isFrozen: Bool

  @ViewBuilder
  func body(content: Content) -> some View {
    HStack {
      content
        .environment(\.detailMode, .limitedViewing)
        .fieldEditionDisabled(true, appearance: .discrete)
        .defaultFieldActionsHidden()
      if hasInfoButton {
        Image.ds.feedback.info.outlined
          .foregroundStyle(Color.ds.text.brand.standard)
          .contentShape(Rectangle())
          .onTapGesture {
            self.showAlert = true
          }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .alert(
      isFrozen && sharingType == .password
        ? CoreL10n.fozenUserLimitAlertTitle : sharingType.limitedRightsAlertTitle,
      isPresented: $showAlert,
      actions: {
        Button(L10n.Core.kwButtonOk) {}
      },
      message: {
        Text(isFrozen && sharingType == .password ? CoreL10n.fozenUserLimitAlertMessage : "")
      }
    )
  }
}

extension SharingType {
  public var limitedRightsAlertTitle: String {
    switch self {
    case .password:
      return CoreL10n.kwLimitedRightMessage
    case .note:
      return CoreL10n.kwSecureNoteLimitedRightMessage
    case .secret:
      return CoreL10n.Secrets.Sharing.limitedRightsMessage
    }
  }
}
