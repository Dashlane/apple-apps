import Foundation
import SwiftUI
import TOTPGenerator

struct HOTPView: View {
    let model: OTPConfiguration
    
    @Binding
    var code: String
        
    @Binding
    var counter: UInt64

    @Environment(\.detailMode)
    var detailMode
    
    let didChange: () -> Void
    let initialCounter: UInt64
    init(model: OTPConfiguration,
         code: Binding<String>,
         initialCounter: UInt64,
         counter: Binding<UInt64>,
         didChange: @escaping () -> Void) {
        self.model = model
        self._code = code
        self._counter = counter
        self.didChange = didChange
        self.initialCounter = initialCounter
    }
    
    var body: some View {
        regenerateButton
        .onAppear {
            if !detailMode.isEditing {
                counter = initialCounter
                generateCode()
            }
        }
    }
    
    var regenerateButton: some View {
        Button(action: {
            increaseCode()
        }) {
            Image(systemName: "arrow.clockwise")
                .foregroundColor(Color(asset: SharedAsset.accentColor))
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private func generateCode() {
        self.code = TOTPGenerator.generate(with: model.type, for: Date(), digits: model.digits, algorithm: model.algorithm, secret: model.secret, currentCounter: counter)
    }
    
    private func increaseCode() {
        counter += 1
        generateCode()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: didChange)
    }

}
