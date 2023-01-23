import Foundation
import SwiftUI

struct ToastCapsule<Content: View>: View {

    @ViewBuilder
    let content: Content

    var body: some View {
        content
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.background)
            .containerShape(Capsule())
            .padding(.top, 1)
            .shadow(color: .black.opacity(0.12), radius: 9, x: 0, y: 3)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {

        #if os(iOS)
        NavigationView {
            List {
                Text("content")
            }.listStyle(.plain)
                .navigationTitle("A title")
                .navigationBarTitleDisplayMode(.inline)


        }
        .overlay(alignment: .top) {
            ToastCapsule {
                Label("Copied !", systemImage: "doc.on.doc")
            }
        }
        .previewDisplayName("Toast over list")

        NavigationView {
            List {
                Text("content")
            }.listStyle(.grouped)
                .navigationTitle("A title")
                .navigationBarTitleDisplayMode(.inline)

        }
        .overlay(alignment: .top) {
            ToastCapsule {
                Text("content") 
            }
        }
        .previewDisplayName("Toast over grouped list")
        #endif

        Rectangle()
            .foregroundColor(.clear)
        .overlay(alignment: .top) {
            ToastCapsule {
                Label("Copied !", systemImage: "doc.on.doc")
            }
        }
        .background(.regularMaterial)
        .previewDisplayName("Toast over vibrant")

    }
}
