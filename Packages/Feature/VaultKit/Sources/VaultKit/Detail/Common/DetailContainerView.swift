import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import DashTypes
import DesignSystem
import DocumentServices
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

  @State var deleteRequest: DeleteVaultItemRequest = .init()
  @State var showCancelConfirmationDialog: Bool = false
  @State var showCollectionAddition: Bool = false
  @State var showSpaceSelector: Bool = false
  @State var titleHeight: CGFloat? = DetailDimension.defaultNavigationBarHeight

  @FeatureState(.documentStorageAllItems) var isDocumentStorageAllItemsEnabled: Bool
  @FeatureState(.documentStorageIds) var isDocumentStorageIdsEnabled: Bool
  @FeatureState(.documentStorageSecrets) var isDocumentStorageSecretsEnabled: Bool

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
    ZStack(alignment: .top) {
      list
        .editionDisabled(!model.mode.isEditing, appearance: .discrete)
        .overlay(loadingView)
        .onReceive(model.eventPublisher) { event in
          switch event {
          case .copy(let success):
            onCopyAction(success)
          case .cancel:
            showCancelConfirmationDialog = true
          default:
            event.toastMessage.map { toast($0, image: event.toastIcon) }
          }
        }

      navigationBar
    }
    .navigationBarBackButtonHidden(true)
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
      L10n.Core.KWVaultItem.UnsavedChanges.title,
      isPresented: $showCancelConfirmationDialog,
      titleVisibility: .visible,
      actions: {
        Button(L10n.Core.KWVaultItem.UnsavedChanges.leave, role: .destructive) {
          model.confirmCancel()
        }
        Button(L10n.Core.KWVaultItem.UnsavedChanges.keepEditing, role: .cancel) {}
      },
      message: {
        Text(L10n.Core.KWVaultItem.UnsavedChanges.message)
      }
    )
    .simultaneousGesture(
      DragGesture(minimumDistance: 20, coordinateSpace: .global)
        .onEnded { value in
          let horizontalAmount = value.translation.width
          if horizontalAmount > 0 && (value.location.x - horizontalAmount) < 10
            && !model.mode.isEditing && !Device.isMac
          {
            dismiss()
          }
        })
  }

  private var list: some View {
    DetailList(offsetEnabled: model.mode == .viewing, titleHeight: $titleHeight) {
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
    }
    .environment(\.detailMode, model.mode)
    .fieldAppearance(.grouped)
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
          .tint(.ds.text.brand.standard)
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .background(Color.ds.container.expressive.neutral.quiet.active)
      .edgesIgnoringSafeArea(.all)
      .fiberAccessibilityElement(children: .combine)
      .fiberAccessibilityLabel(Text(L10n.Core.accessibilityDeletingItem))
    }
  }
}

extension DetailContainerView {
  fileprivate var navigationBar: some View {
    NavigationBar(
      leading:
        leadingButton
        .id(model.mode),
      title:
        title
        .accessibilityAddTraits(.isHeader)
        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        .foregroundColor(.ds.text.neutral.catchy),
      titleAccessory: titleAccessory,
      trailing:
        trailingButton
        .id(model.mode),
      height: !model.mode.isEditing ? titleHeight : nil
    )
    .accentColor(.ds.text.brand.standard)
  }

  @ViewBuilder
  fileprivate var leadingButton: some View {
    if case .updating = model.mode {
      Button(L10n.Core.kwEditClose) {
        withAnimation(.easeInOut) {
          model.cancel()
        }
      }
    } else if model.mode.isAdding {
      Button(L10n.Core.cancel, action: dismiss)
    } else if specificBackButton == .close {
      Button(L10n.Core.kwButtonClose, action: dismiss)
    } else if canDismiss || specificBackButton == .back {
      BackButton(color: .ds.text.brand.standard, action: dismiss)
    }
  }

  fileprivate var canDismiss: Bool {
    model.mode.isAdding || isPresented
  }

  @ViewBuilder
  fileprivate var title: some View {
    if case .viewing = model.mode {
      Text(model.item.localizedTitle)
    } else if model.mode.isAdding {
      Text(model.item.addTitle)
    } else if case .updating = model.mode {
      Text(L10n.Core.kwEdit)
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
        Button(L10n.Core.kwSave) {
          withAnimation(.easeInOut) {
            save()
          }
        }
        .disabled(!model.canSave)
        .loading(isLoading: model.isSaving)
      }
    } else {
      Button(L10n.Core.kwEdit) {
        withAnimation(.easeInOut) {
          model.mode = .updating
        }
      }
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
      return L10n.Core.KWAuthentifiantIOS.Domains.update
    case .save:
      return L10n.Core.KWVaultItem.Changes.saved
    case .cancel, .copy:
      return nil
    }
  }

  fileprivate var toastIcon: Image? {
    switch self {
    case .copy:
      return .ds.action.copy.outlined
    case .save, .domainsUpdate:
      return .ds.feedback.success.outlined
    case .cancel:
      return nil
    }
  }
}

struct DetailContainerView_Previews: PreviewProvider {
  private static let credential: Credential = {
    var amazon = PersonalDataMock.Credentials.amazon
    amazon.creationDatetime = Date().substract(days: 30)
    amazon.userModificationDatetime = Date().substract(days: 2)
    return amazon
  }()

  static var previews: some View {
    MultiContextPreview {
      DetailContainerView(service: .mock(item: credential, mode: .viewing)) {
        Section {
          Text("Content")
        }
      }
      DetailContainerView(service: .mock(item: credential, mode: .updating)) {
        Section {
          Text("Content")
        }
      }
    }
  }
}
