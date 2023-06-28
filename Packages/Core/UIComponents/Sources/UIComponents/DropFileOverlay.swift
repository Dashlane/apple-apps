import Foundation
import SwiftUI
import DesignSystem

public struct DropFileOverlay: View {

    public init() {}

    public var body: some View {
        SwiftUI.Color.ds.background.default.opacity(0.8)
            .edgesIgnoringSafeArea(.all)
            .overlay {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(SwiftUI.Color.ds.text.neutral.quiet, style: StrokeStyle(lineWidth: 5, dash: [10]))
                    .padding(10)
                    .overlay {
                        Image.ds.arrowDown.outlined
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60)
                            .foregroundColor(.ds.text.neutral.quiet)
                    }
                    .edgesIgnoringSafeArea(.all)
            }
    }
}

struct DropFileOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            Text("My view")
                .font(.headline)
            Text("my viewmy viewmy viewmy viewmy view")
            Text("my viewmy viewmy viewmy viewmy viewmy view")
                .font(.callout)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .overlay {
            DropFileOverlay()
        }
    }
}
