import Foundation
import SwiftUI
import CorePersonalData
import Combine
import CoreSession
import UIDelight
import DashlaneAppKit
import SwiftTreats
import DashTypes
import IconLibrary
import UIComponents
import CoreFeature
import UIKit
import DesignSystem

struct SecureNotesDetailView: View {

    @ObservedObject
    var model: SecureNotesDetailViewModel

    @Environment(\.isPresented)
    private var isPresented

    @State
    private var showDocumentStorage: Bool = false

    @State
    private var showColorPicker: Bool = false

    @State
    private var showSpaceSelector: Bool = false

    @FocusState
    var isEditingContent: Bool

    @Environment(\.toast)
    var toast

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            mainContent
                .padding(.bottom, toolbarHeight)
        }
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
            .navigationTitle(L10n.Localizable.KWSecureNoteIOS.spaceId)
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
            .fiberAccessibilityLabel(Text(L10n.Localizable.kwDelete))
        }
    }

        @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    SecureNotesDetailFields(
                        model: model.secureNotesDetailFieldsModelFactory.make(service: model.service),
                        isEditingContent: $isEditingContent
                    )
                    .frame(minHeight: geometry.size.height, alignment: .top) 
                    .environment(\.detailMode, model.mode)
                }
                .frame(height: geometry.size.height, alignment: .top)
            }
            sharingInfo
        }
        .padding(.horizontal, 5)
        .background(Color.ds.background.default)
    }

        private var toolbar: some View {
        SecureNotesDetailToolbar(
            model: model.secureNotesDetailToolbarFactory.make(service: model.service),
            toolbarHeight: toolbarHeight,
            isEditingContent: $isEditingContent,
            showDocumentStorage: $showDocumentStorage,
            showColorPicker: $showColorPicker,
            showSpaceSelector: $showSpaceSelector
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
        .navigationTitle(L10n.Localizable.KWSecureNoteIOS.colorTitle)
    }

        @ViewBuilder
    private var sharingInfo: some View {
        if model.item.metadata.isShareable {
            SharingMembersDetailLink(model: model.sharingMembersDetailLinkModelFactory.make(item: model.item))
        }
    }
}

struct SecureNotesDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            SecureNotesDetailView(model: MockVaultConnectedContainer().makeSecureNotesDetailViewModel(item: PersonalDataMock.SecureNotes.thinkDifferent, mode: .viewing))
            SecureNotesDetailView(model: MockVaultConnectedContainer().makeSecureNotesDetailViewModel(item: PersonalDataMock.SecureNotes.thinkDifferent, mode: .updating))
        }
    }
}
