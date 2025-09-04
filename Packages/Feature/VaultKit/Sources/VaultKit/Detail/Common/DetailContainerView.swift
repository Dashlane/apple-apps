import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSession
import CoreTypes
import DesignSystem
import DocumentServices
import LogFoundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct DetailContainerView<Content: View, SharingSection: View, Item: VaultItem & Equatable>:
  View, DismissibleDetailView
{
  @ObservedObject var model: DetailContainerViewModel<Item>

  @Environment(\.detailContainerViewSpecificBackButton) var specificBackButton
  @Environment(\.detailContainerViewSpecificDismiss) public var dismissView
  @Environment(\.detailContainerViewSpecificSave) var specificSave
  @Environment(\.dismiss) public var dismissAction
  @Environment(\.isPresented) private var isPresented
  @Environment(\.toast) var toast
  @Environment(\.authenticationMethod) var authenticationMethod: AuthenticationMethod?

  @State var deleteRequest: DeleteVaultItemRequest = .init()
  @State var showCancelConfirmationDialog: Bool = false
  @State var showCollectionAddition: Bool = false
  @State var showSpaceSelector: Bool = false

  @FeatureState(.documentStorageAllItems) var isDocumentStorageAllItemsEnabled: Bool
  @FeatureState(.documentStorageIds) var isDocumentStorageIdsEnabled: Bool

  let content: Content
  let sharingSection: SharingSection

  public init(
    service: DetailService<Item>,
    @ViewBuilder content: () -> Content,
    @ViewBuilder sharingSection: () -> SharingSection
  ) {
    self.model = .init(service: service)
    self.content = content()
    self.sharingSection = sharingSection()
  }

  public var body: some View {
    list
      .fieldEditionDisabled(!model.mode.isEditing, appearance: .discrete)
      .overlay(loadingView)
      .onReceive(model.eventPublisher) { event in
        switch event {
        case .copy(let success):
          onCopyAction(success)
        case .askConfirmationCancel:
          showCancelConfirmationDialog = true
        default:
          event.toastMessage.map { toast($0, image: event.toastIcon) }
        }
      }
      .userActivity(.viewItem, isActive: model.advertiseUserActivity) { activity in
        activity.update(with: model.item)
      }
      .onAppear(perform: model.reportDetailViewAppearance)
      .makeShortcuts(
        model: model,
        edit: { model.mode = .updating },
        save: { save() },
        cancel: { model.mode = .viewing },
        close: { dismiss() },
        delete: askDelete
      )
      .confirmationDialog(
        CoreL10n.KWVaultItem.UnsavedChanges.title,
        isPresented: $showCancelConfirmationDialog,
        titleVisibility: .visible,
        actions: {
          Button(CoreL10n.KWVaultItem.UnsavedChanges.leave, role: .destructive) {
            model.confirmCancel()
          }
          Button(CoreL10n.KWVaultItem.UnsavedChanges.keepEditing, role: .cancel) {}
        },
        message: {
          Text(CoreL10n.KWVaultItem.UnsavedChanges.message)
        }
      )
      .deleteItemAlert(request: $deleteRequest, deleteAction: delete)
      .navigationBarBackButtonHidden(shouldHideBackButton)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          leadingButton
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          trailingButton
        }
      }
      .loading(model.isSaving)
  }

  private var list: some View {
    DetailList(title: title) {
      content

      itemOrganizationSection
      sharingSection
      attachmentsSection
      preferencesSection

      if model.mode == .viewing || model.mode == .limitedViewing {
        DetailSyncAndDatesSection(item: model.item)
      }

      if DiagnosticMode.isEnabled {
        DetailDebugInfoSection(item: model.item)
      }

      if case .updating = model.mode {
        deleteSection
      }
    } titleAccessory: {
      titleAccessory
    }
    .detailListCollapseMode(model.mode.isEditing ? .always : .onScroll)
    .environment(\.detailMode, model.mode)
    .navigation(isActive: $showSpaceSelector) {
      spaceSelectorList
    }
    .sheet(isPresented: $showCollectionAddition) {
      collectionAdditionView
    }
  }

  @ViewBuilder
  private var loadingView: some View {
    if model.isLoading {
      VStack {
        Spacer()
        ProgressView()
          .progressViewStyle(.indeterminate)
          .tint(.ds.text.brand.standard)
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .background(Color.ds.container.expressive.neutral.quiet.active)
      .edgesIgnoringSafeArea(.all)
      .fiberAccessibilityElement(children: .combine)
      .fiberAccessibilityLabel(Text(CoreL10n.accessibilityDeletingItem))
    }
  }
}

extension DetailContainerView {
  fileprivate var shouldHideBackButton: Bool {
    model.mode.isEditing || specificBackButton == .close
  }

  @ViewBuilder
  fileprivate var leadingButton: some View {
    if case .updating = model.mode {
      Button(CoreL10n.kwEditClose) {
        withAnimation(.easeInOut) {
          model.cancel()
        }
      }
      .foregroundStyle(Color.ds.text.brand.standard)
    } else if model.mode.isAdding {
      Button(CoreL10n.cancel, action: dismiss)
        .foregroundStyle(Color.ds.text.brand.standard)
    } else if specificBackButton == .close {
      Button(CoreL10n.kwButtonClose, action: dismiss)
        .foregroundStyle(Color.ds.text.brand.standard)
    }
  }

  fileprivate var canDismiss: Bool {
    model.mode.isAdding || isPresented
  }

  fileprivate var title: Text {
    if case .viewing = model.mode {
      Text(model.item.localizedTitle)
    } else if model.mode.isAdding {
      Text(model.item.addTitle)
    } else if case .updating = model.mode {
      Text(CoreL10n.kwEdit)
    } else {
      Text(model.item.localizedTitle)
    }
  }

  fileprivate var titleAccessory: some View {
    VaultItemIconView(isListStyle: false, isLarge: true, model: model.iconViewModel)
      .equatable()
      .accessibilityHidden(true)
  }

  @ViewBuilder
  fileprivate var trailingButton: some View {
    if model.mode.isEditing {
      if !model.isSaving {
        Button(CoreL10n.kwSave) {
          withAnimation(.easeInOut) {
            save()
          }
        }
        .disabled(!model.canSave)
        .foregroundStyle(
          model.canSave ? Color.ds.text.brand.standard : Color.ds.text.oddity.disabled)
      }
    } else {
      Button(CoreL10n.kwEdit) {
        withAnimation(.easeInOut) {
          model.mode = .updating
        }
      }
      .foregroundStyle(Color.ds.text.brand.standard)
    }
  }
}

extension DetailContainerView where SharingSection == EmptyView {
  public init(
    service: DetailService<Item>,
    @ViewBuilder content: () -> Content
  ) {
    self.model = .init(service: service)
    self.content = content()
    self.sharingSection = EmptyView()
  }
}

extension DetailServiceEvent {
  fileprivate var toastMessage: String? {
    switch self {
    case .domainsUpdate:
      return CoreL10n.KWAuthentifiantIOS.Domains.update
    case .save:
      return CoreL10n.KWVaultItem.Changes.saved
    case .wifiConnection:
      return CoreL10n.WiFi.Toast.connected
    case .askConfirmationCancel, .copy:
      return nil
    }
  }

  fileprivate var toastIcon: Image? {
    switch self {
    case .copy:
      return .ds.action.copy.outlined
    case .save, .domainsUpdate:
      return .ds.feedback.success.outlined
    case .wifiConnection:
      return .ds.item.wifi.outlined
    case .askConfirmationCancel:
      return nil
    }
  }
}

#Preview {
  var amazon = PersonalDataMock.Credentials.amazon
  amazon.creationDatetime = Date().substract(days: 30)
  amazon.userModificationDatetime = Date().substract(days: 2)

  return DetailContainerView(service: .mock(item: amazon, mode: .viewing)) {
    Section {
      Text("Content")
    }
  }
}
