import CoreLocalization
import CoreSession
import CoreTypes
import DesignSystem
import DesignSystemExtra
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

public struct BiometryView: View {
  @StateObject
  var model: BiometryViewModel

  public init(model: @autoclosure @escaping () -> BiometryViewModel) {
    self._model = .init(wrappedValue: model())
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
        NativeNavigationBarBackButton(CoreL10n.kwBack) {
          Task {
            await model.perform(.cancel)
          }
        }
      }
    }
    .onAppear {
      Task {
        if !self.model.manualLockOrigin {
          await self.model.validateBiometry()
        }
      }
    }
    .animation(.default, value: model.isPerformingEvent)
    .reportPageAppearance(.unlockBiometric)
  }

  var centerView: some View {
    VStack {
      Text(CoreL10n.kwLockBiometryTypeLoadingMsg(model.biometryType.displayableName))
        .foregroundStyle(Color.ds.text.neutral.catchy)

      Button(
        action: {
          Task {
            await model.validateBiometry()
          }
        },
        label: {
          Image(biometry: model.biometryType)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 58, height: 58)
            .foregroundStyle(Color.ds.text.neutral.catchy)
        }
      )
    }
    .opacity(!model.isPerformingEvent ? 1 : 0.5)
    .disabled(model.isPerformingEvent)
  }
}

struct BiometryView_Previews: PreviewProvider {
  static var previews: some View {
    BiometryView(model: .mock(type: .touchId))
    BiometryView(model: .mock(type: .faceId))
    BiometryView(model: .mock(type: .opticId))
  }
}
