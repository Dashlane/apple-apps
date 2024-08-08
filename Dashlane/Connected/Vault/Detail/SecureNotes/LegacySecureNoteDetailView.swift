import Combine
import CoreFeature
import CoreLocalization
import CorePersonalData
import CoreSession
import DashTypes
import DesignSystem
import Foundation
import IconLibrary
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit
import VaultKit

struct LegacySecureNoteDetailView: View {
  @StateObject var model: SecureNotesDetailViewModel

  @Environment(\.isPresented)
  private var isPresented

  @State
  private var showDocumentStorage: Bool = false

  @State
  private var showColorPicker: Bool = false

  @State
  private var showSpaceSelector: Bool = false

  @State
  private var showCancelConfirmationDialog: Bool = false

  @State
  private var showPreview: Bool = false

  @FocusState
  var isEditingContent: Bool

  @Environment(\.toast)
  var toast

  init(model: @escaping @autoclosure () -> SecureNotesDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    VStack(spacing: 0) {
      navigationBar
      mainContent
        .padding(.bottom, toolbarHeight)
    }
    .navigationBarBackButtonHidden(true)
    .overlay(toolbar, alignment: .bottom)
    .userActivity(.viewItem, isActive: model.advertiseUserActivity) { activity in
      activity.update(with: model.item)
    }
    .onAppear {
      model.reportDetailViewAppearance()
      UITextView.appearance().backgroundColor = .clear
    }
    .onDisappear {
      UITextView.appearance().backgroundColor = nil
    }
    .overlay(loadingView)
    .onReceive(model.eventPublisher.receive(on: DispatchQueue.main)) { event in
      switch event {
      case .cancel:
        self.showCancelConfirmationDialog = true
      default:
        break
      }
    }
    .navigation(isActive: $showColorPicker) {
      colorPicker
        .navigationBarTitleDisplayMode(.inline)
    }
    .navigation(isActive: $showSpaceSelector) {
      SelectionListView(
        selection: $model.selectedUserSpace,
        items: model.availableUserSpaces,
        selectionDidChange: model.saveIfViewing
      )
      .navigationTitle(CoreLocalization.L10n.Core.KWSecureNoteIOS.spaceId)
      .navigationBarTitleDisplayMode(.inline)
    }
    .navigation(isActive: $showDocumentStorage) {
      model.makeAttachmentsListViewModel().map {
        AttachmentsListView(model: $0)
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }

  private var navigationBar: some View {
    SecureNotesDetailNavigationBar(
      model: model.secureNotesDetailNavigationBarModelFactory.make(
        service: model.service,
        isEditingContent: $isEditingContent
      )
    )
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
      .fiberAccessibilityLabel(Text(CoreLocalization.L10n.Core.kwDelete))
    }
  }

  @ViewBuilder
  private var mainContent: some View {
    VStack(spacing: 0) {
      GeometryReader { geometry in
        ScrollView(.vertical) {
          SecureNotesDetailFields(
            model: model.secureNotesDetailFieldsModelFactory.make(service: model.service),
            isEditingContent: $isEditingContent,
            showLivePreview: $showPreview
          )
          .frame(minHeight: geometry.size.height, alignment: .top)
          .environment(\.detailMode, model.mode)
        }
        .frame(height: geometry.size.height, alignment: .top)
      }
      sharingInfo
        .padding()
    }
    .padding(.horizontal, 5)
    .background(Color.ds.background.default)
    .confirmationDialog(
      CoreLocalization.L10n.Core.KWVaultItem.UnsavedChanges.title,
      isPresented: $showCancelConfirmationDialog,
      titleVisibility: .visible,
      actions: {
        Button(
          CoreLocalization.L10n.Core.KWVaultItem.UnsavedChanges.leave,
          role: .destructive
        ) {
          model.confirmCancel()
        }
        Button(
          CoreLocalization.L10n.Core.KWVaultItem.UnsavedChanges.keepEditing,
          role: .cancel
        ) {

        }
      },
      message: {
        Text(CoreLocalization.L10n.Core.KWVaultItem.UnsavedChanges.message)
      }
    )
  }

  private var toolbar: some View {
    SecureNotesDetailToolbar(
      model: model.secureNotesDetailToolbarFactory.make(service: model.service),
      toolbarHeight: toolbarHeight,
      isEditingContent: $isEditingContent,
      showDocumentStorage: $showDocumentStorage,
      showColorPicker: $showColorPicker,
      showSpaceSelector: $showSpaceSelector,
      showPreview: $showPreview
    )
  }

  private var toolbarHeight: CGFloat {
    Device.isIpadOrMac ? 50 : 40
  }

  private var colorPicker: some View {
    SelectionListView(
      selection: $model.selectedColor,
      items: SecureNoteColor.allCases,
      selectionDidChange: model.saveIfViewing
    ) { color in
      HStack {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
          .frame(width: 30, height: 20)
          .foregroundColor(color.color)
        Text(color.localizedName)
      }
    }
    .navigationTitle(CoreLocalization.L10n.Core.KWSecureNoteIOS.colorTitle)
  }

  @ViewBuilder
  private var sharingInfo: some View {
    if model.item.isShared {
      SharingMembersDetailLink(
        model: model.sharingMembersDetailLinkModelFactory.make(item: model.item))
    }
  }
}

struct LegacySecureNoteDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      LegacySecureNoteDetailView(
        model: MockVaultConnectedContainer().makeSecureNotesDetailViewModel(
          item: PersonalDataMock.SecureNotes.thinkDifferent, mode: .viewing))
      LegacySecureNoteDetailView(
        model: MockVaultConnectedContainer().makeSecureNotesDetailViewModel(
          item: PersonalDataMock.SecureNotes.thinkDifferent, mode: .updating))
    }
  }
}
