import Foundation
import SwiftUI

struct StackNavigationView<RootContent: View>: View {
    
    @Binding var subviews: [NavigationWrapperView]
    let rootView: () -> RootContent
    
    var body: some View {
        ZStack {
            if let view = subviews.last {
                view.content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(view.id)
            }
            rootView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .hidden(!subviews.isEmpty)
        }
        .toasterOn()
    }
}
