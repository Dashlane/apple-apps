import DesignSystem
import Foundation
import LoginKit
import SwiftUI

struct DeviceTransferPendingRequestView: View {

  @Environment(\.toast)
  var toast

  @StateObject
  var model: DeviceTransferPendingRequestViewModel

  @Environment(\.dismiss)
  var dismiss

  init(model: @escaping @autoclosure () -> DeviceTransferPendingRequestViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      if model.isLoading {
        LottieProgressionFeedbacksView(state: model.progressState)
      } else {
        ScrollView {
          mainView
        }
        overlayView
          .navigationTitle(L10n.Localizable.Mpless.D2d.trustedNavigationTitle)
          .navigationBarTitleDisplayMode(.inline)
      }
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    .animation(.default, value: model.isLoading)
  }

  var mainView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(L10n.Localizable.Mpless.D2d.Universal.pendingTransferTitle)
        .font(.title)
        .foregroundStyle(Color.ds.text.neutral.catchy)
      Text(L10n.Localizable.Mpless.D2d.Universal.pendingTransferMessage)
        .font(.body)
        .foregroundStyle(Color.ds.text.neutral.standard)
      VStack(alignment: .leading, spacing: 12) {
        Text(model.pendingTransfer.receiver.deviceName)
          .textStyle(.body.standard.strong)
          .foregroundStyle(Color.ds.text.neutral.catchy)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(model.displayLocation)
          .textStyle(.body.standard.strong)
          .foregroundStyle(Color.ds.text.neutral.catchy)
        Text(model.displayDate())
          .textStyle(.body.standard.strong)
          .foregroundStyle(Color.ds.text.neutral.catchy)

      }
      .padding(.horizontal, 24)
      .padding(.vertical, 16)
      .background {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(Color.ds.container.agnostic.neutral.supershy)
      }
      Infobox(L10n.Localizable.Mpless.D2d.Universal.pendingTransferInfoboxTitle)
        .padding(.top, 8)
      Spacer()
    }.padding(24)

  }

  var overlayView: some View {
    VStack(spacing: 8) {
      Spacer()
      Button(L10n.Localizable.Mpless.D2d.Universal.pendingTransferPrimaryCta) {
        Task {
          await model.confirmRequest()
        }
      }
      .style(mood: .brand, intensity: .catchy)

      Button(L10n.Localizable.Mpless.D2d.Universal.pendingTransferSecondaryCta) {
        dismiss()
        toast(L10n.Localizable.Mpless.D2d.Universal.Trusted.rejectedToast)
      }
      .style(mood: .brand, intensity: .quiet)
    }
    .buttonStyle(.designSystem(.titleOnly))
    .padding(24)
  }
}

struct DeviceTransferPendingRequestView_Preview: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DeviceTransferPendingRequestView(model: .mock)
    }
  }
}
