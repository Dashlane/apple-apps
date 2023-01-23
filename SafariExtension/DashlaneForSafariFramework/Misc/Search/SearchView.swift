import SwiftUI

struct SearchView: View {
    
    @Binding var text: String
    
    let placeholder: String

    var body: some View {
        
        ZStack {
            HStack {
                Image(asset: Asset.search)
                    .foregroundColor(Color(asset: Asset.primaryHighlight))
                Spacer()
            }
            .padding(.leading, 10)
            SearchTextFieldView(text: $text,
                                placeholder: placeholder,
                                validate: { _ in })
        }
        .padding(.vertical, 6)
    }
}

#if DEBUG

struct SearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        PopoverPreviewScheme {
            SearchView(text: .constant("Départ"),
                       placeholder: "placeholder")
                .padding()
        }
    }
}

#endif
