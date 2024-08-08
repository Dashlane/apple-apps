#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import CoreSession
  import SwiftTreats
  import DashTypes
  import UIDelight
  import CoreLocalization
  import DesignSystem
  import UIComponents

  public struct BiometryView: View {
    @StateObject
    var model: BiometryViewModel
    let showProgressIndicator: Bool

    public init(
      model: @autoclosure @escaping () -> BiometryViewModel, showProgressIndicator: Bool = true
    ) {
      self._model = .init(wrappedValue: model())
      self.showProgressIndicator = showProgressIndicator
    }

    public var body: some View {
      GravityAreaVStack(
        top: LoginLogo(login: self.model.login),
        center: centerView
      )
      .loginAppearance()
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          BackButton(
            label: L10n.Core.kwBack,
            color: .ds.text.neutral.catchy
          ) {
            model.cancel()
          }
        }
      }
      .onAppear {
        self.model.logAskAuthentication()
        if !self.model.manualLockOrigin {
          Task {
            await self.model.validate()
          }
        }
      }
      .reportPageAppearance(.unlockBiometric)
      .animation(.default, value: showProgressIndicator)
      .loading(
        isLoading: model.shouldDisplayProgress && showProgressIndicator,
        loadingIndicatorOffset: true)
    }

    var centerView: some View {
      VStack {
        Text(L10n.Core.kwLockBiometryTypeLoadingMsg(model.biometryType.displayableName))
          .foregroundColor(.ds.text.neutral.catchy)

        Button(
          action: {
            Task {
              await self.model.validate()
            }
          },
          label: {
            Image(asset: model.biometryType == .touchId ? Asset.fingerprint : Asset.faceId)
              .foregroundColor(.ds.text.neutral.catchy)
          }
        )
        .opacity(!model.shouldDisplayProgress ? 1 : 0.5)
        .disabled(model.shouldDisplayProgress)
      }
    }

    private var biometryImage: Image {
      if model.biometryType == .touchId {
        return Asset.fingerprint.swiftUIImage
      } else {
        return Asset.faceId.swiftUIImage
      }
    }
  }

  struct BiometryView_Previews: PreviewProvider {
    static var previews: some View {
      BiometryView(model: .mock(type: .touchId))
      BiometryView(model: .mock(type: .faceId))
    }
  }
#endif
