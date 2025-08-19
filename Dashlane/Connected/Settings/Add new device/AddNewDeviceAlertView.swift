import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import DesignSystem
import SwiftUI
import UIComponents

struct AddNewDeviceAlertView: View {

  @State
  var showNewDeviceFlow = false

  @Environment(\.dismiss)
  var dismiss

  let model: AddNewDeviceAlertViewModel

  let l10n = CoreL10n.AddNewDeviceWarning.self

  var body: some View {
    ZStack {
      loginView
      if showNewDeviceFlow {
        AddNewDeviceView(model: model.makeAddNewDeviceViewModel())
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .loginAppearance()
    .navigationBarBackButtonHidden()
    .navigationTitle(l10n.navigationTitle)
    .navigationBarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  var loginView: some View {
    topView
      .overlay(bottomView)
  }

  @ViewBuilder
  var topView: some View {
    VStack(alignment: .leading, spacing: 8) {
      DS.ExpressiveIcon(.ds.protection.outlined)
        .controlSize(.extraLarge)
        .style(mood: .warning, intensity: .quiet)

      Text(l10n.title)
        .textStyle(.title.section.large)
        .padding(.top, 4)

      Text(l10n.message1)
        .textStyle(.body.standard.regular)

      Text(l10n.message2)
        .textStyle(.body.standard.regular)

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 24)
  }

  var bottomView: some View {
    VStack(spacing: 23) {
      Spacer()
      Button(l10n.authorizeCta) {
        showNewDeviceFlow = true
      }
      .buttonStyle(.designSystem(.titleOnly))
      .style(mood: .brand, intensity: .catchy)

      Button(CoreL10n.cancel) {
        dismiss()
      }
      .buttonStyle(.borderless)
      .foregroundStyle(Color.ds.text.brand.standard)
    }
    .padding(.horizontal, 24)
  }
}

struct AddNewDeviceAlertView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AddNewDeviceAlertView(
        model: AddNewDeviceAlertViewModel(
          qrCode: "",
          addNewDeviceViewModelFactory: .init({ _ in
            .mock(accountType: .invisibleMasterPassword)
          }))
      )
    }
  }
}
