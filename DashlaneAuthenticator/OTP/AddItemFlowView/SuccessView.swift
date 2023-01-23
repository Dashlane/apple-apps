import Foundation
import SwiftUI
import UIComponents

struct SuccessView: View {
    
    let completion: () -> Void
    
    var body: some View {
        VStack {
            LottieView(.success, loopMode: .playOnce)
                .frame(width: 78, height: 78, alignment: .center)
        }
        .backgroundColorIgnoringSafeArea(.ds.container.expressive.brand.catchy.idle)
        .navigationBarStyle(.transparent)
        .navigationBarBackButtonHidden(true)
        .accessibilityIdentifier("Success view")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion()
            }
        }
    }
}

struct SuccessView_previews: PreviewProvider {
    static var previews: some View {
        SuccessView() {}
    }
}
