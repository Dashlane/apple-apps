import CorePersonalData
import CoreSession
import CoreUserTracking
import DesignSystem
import SwiftUI

struct SecureArchiveSectionContent: View {

  @StateObject
  var viewModel: SecureArchiveSectionContentViewModel

  @State
  private var showExportView = false

  @State
  private var showExportOnlyPersonalDataAlert = false

  @State
  private var showExportDisabledAlert = false

  init(viewModel: @autoclosure @escaping () -> SecureArchiveSectionContentViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var body: some View {
    Button {
      switch viewModel.exportFlowState {
      case .limited:
        showExportOnlyPersonalDataAlert = true
      case .disabled:
        showExportDisabledAlert = true
      case .complete:
        showExportView = true
      }
    } label: {
      Text(L10n.Localizable.export)
        .foregroundColor(.ds.text.neutral.standard)
        .textStyle(.body.standard.regular)
    }
    .bottomSheet(
      isPresented: $showExportOnlyPersonalDataAlert,
      content: {
        limitedExportBottomSheet
      }
    )
    .fullScreenCover(isPresented: $showExportView) {
      ExportSecureArchiveView(
        viewModel: viewModel.exportSecureArchiveViewModelFactory.make(
          onlyExportPersonalSpace: viewModel.exportFlowState == .limited))
    }
    .alert(
      L10n.Localizable.dpsExportRestrictedAlertTitle,
      isPresented: $showExportDisabledAlert,
      actions: {
        Button(L10n.Localizable.dpsExportRestrictedAction, role: .cancel) {}
      },
      message: {
        Text(L10n.Localizable.dpsExportRestrictedAlertMessage)
      })
  }

  @ViewBuilder
  var limitedExportBottomSheet: some View {
    VStack(spacing: 40) {
      VStack(spacing: 8) {
        Text(L10n.Localizable.dpsExportOnlyYourPersonalData)
          .textStyle(.title.section.medium)
          .lineLimit(nil)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        Text(L10n.Localizable.dpsYourCompanyPolicyPreventsExporting)
          .textStyle(.body.standard.regular)
          .lineLimit(nil)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .frame(maxWidth: .infinity, alignment: .leading)
        Infobox(L10n.Localizable.dpsBeforeContinuing)
          .padding(.top, 8)
      }
      .fixedSize(horizontal: false, vertical: true)
      VStack(spacing: 8) {
        Button(L10n.Localizable.kwCmContinue) {
          showExportOnlyPersonalDataAlert = false
          showExportView = true
        }
        Button(L10n.Localizable.dpsCancel, action: { showExportOnlyPersonalDataAlert = false })
          .style(intensity: .quiet)
      }
      .buttonStyle(.designSystem(.titleOnly))
    }
    .padding(.horizontal, 24)
  }
}

struct SecureArchiveSectionContent_Previews: PreviewProvider {
  static var previews: some View {
    SecureArchiveSectionContent(viewModel: .mock(status: .Mock.freeTrial))
  }
}
