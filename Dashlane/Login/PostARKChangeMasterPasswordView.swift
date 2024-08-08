import Foundation
import SwiftUI
import UIComponents

struct PostARKChangeMasterPasswordView: View {
  @StateObject
  var model: PostARKChangeMasterPasswordViewModel

  @Environment(\.dismiss)
  var dismiss

  var body: some View {
    MigrationProgressView(model: model.makeMigrationProgressViewModel())
      .navigationBarBackButtonHidden()
      .onReceive(model.dismissPublisher) {
        dismiss()
      }
  }
}

struct PostARKChangeMasterPasswordView_Previews: PreviewProvider {
  static var previews: some View {
    PostARKChangeMasterPasswordView(model: .mock)
  }
}
