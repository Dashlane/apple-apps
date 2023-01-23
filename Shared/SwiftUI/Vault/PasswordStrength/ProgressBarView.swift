import Foundation
import SwiftUI
import Combine

struct ProgressBarView: View {
    let progress: CGFloat
    let total: CGFloat

    let fillColor: Color
    let backgroundColor: Color

    init(progress: CGFloat,
         total: CGFloat = 5,
         fillColor: Color,
         backgroundColor: Color = Color(asset: SharedAsset.fieldBackground)) {
        self.progress = progress
        self.total = total
        self.fillColor = fillColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        GeometryReader { reader in
            Capsule()
                .foregroundColor(fillColor)
                .frame(width: (progress / total) * reader.size.width,
                       alignment: .leading)
        }
        .background(Capsule()
                        .foregroundColor(backgroundColor))
        .frame(height: 4)
    }
}

struct ProgressBarView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ForEach(0..<5) { value in
                ProgressBarView(progress: CGFloat(value), fillColor: Color.red)
            }
        }.padding().previewLayout(.sizeThatFits)
    }
}
