import SwiftUI
import Lottie

struct LoadingView: View {
    var body: some View {
        LottieView(type: .coloredAnimation(name: "logo_undefinite_loading", lightMode: Asset.dashGreenCopy.color, darkMode: .white))
            .frame(alignment: .center)
            .scaleEffect(0.25)
        
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
