#if canImport(UIKit)
import CorePremium
import SwiftUI
import UIDelight
import CoreLocalization

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
                .padding(.bottom, 10)
                .scaleEffect(1.5)
                .tint(.white)

            Text(viewModel.stepText)
                .font(.callout)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .backgroundColorIgnoringSafeArea(.black.opacity(0.8))
        #if !os(macOS)
        .navigationBarBackButtonHidden(true)
        .navigationBarStyle(.transparent)
        #endif
        .transition(.opacity)
        .onReceive(viewModel.dismissPublisher) {
            self.action($0)
        }
        .onAppear {
            viewModel.purchase()
        }
    }
}
#endif
