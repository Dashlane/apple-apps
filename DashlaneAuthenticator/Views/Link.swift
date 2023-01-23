import Foundation
import SwiftUI
import UIDelight

public struct Link: View {
    
    let title: String
    let url: URL
    
    @BindingOrState
    var isPresented: Bool
    
    public init(title: String,
                url: URL,
                isPresented: Binding<Bool>? = nil) {
        self.title = title
        self.url = url
        if let binding = isPresented {
            self._isPresented = .init(binding)
        } else {
            self._isPresented = .init(wrappedValue: false)
        }
    }
    
    public var body: some View {
        Button(action: {
            self.isPresented = true
        }, label: {
            Text(title)
                .underline()
                .font(.headline)
                .foregroundColor(.ds.text.brand.standard)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        })
        .safariSheet(isPresented: $isPresented, url: url)
        .fiberAccessibilityRemoveTraits(.isButton)
        .fiberAccessibilityAddTraits(.isLink)
    }
}

struct Link_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            Link(title: "This is a link", url: URL(string: "google.com")!)
        }
    }
}
