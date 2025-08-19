import CoreLocalization
import CorePremium
import SwiftUI
import UIDelight

struct PurchaseProcessView: View {

  enum Action {
    case success(plan: PurchasePlan)
    case cancellation
    case failure(_ error: Error)
  }

  private enum Step {
    case purchasing
    case verifying
  }

  @ObservedObject
  var viewModel: PurchaseProcessViewModel

  let action: (Action) -> Void

  var body: some View {
    VStack {
      Spacer()

      ProgressView()
        .controlSize(.large)
        .progressViewStyle(.indeterminate)
        .padding(.bottom, 20)

      Text(viewModel.stepText)
        .font(.callout)
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .background(Color.black.opacity(0.8), ignoresSafeAreaEdges: .all)
    .navigationBarBackButtonHidden(true)
    .transition(.opacity)
    .onReceive(viewModel.dismissPublisher) {
      self.action($0)
    }
    .onAppear {
      viewModel.purchase()
    }
  }
}
