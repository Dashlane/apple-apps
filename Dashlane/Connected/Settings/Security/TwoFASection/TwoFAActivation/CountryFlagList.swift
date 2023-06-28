import Foundation
import SwiftUI
import UIComponents

struct CountryFlagList: View {

    @Environment(\.dismiss)
    private var dismiss

    let countryFlags: [Country]

    @Binding
    var selectedFlag: Country

    var body: some View {
        ScrollViewReader { proxy in
            list
                .navigationTitle(Text("Country")) 
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButton(action: dismiss.callAsFunction)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            proxy.scrollTo(selectedFlag, anchor: .top)
                        }
                    }
                }
        }
        .navigationBarStyle(.default)
    }

    var list: some View {
        List(countryFlags, id: \.self) { country in
            HStack {
                Text(country.flag)
                Text(country.name)
                Spacer()
                if selectedFlag == country {
                    Image(systemName: "checkmark")
                        .foregroundColor(.ds.text.brand.quiet)
                        .fiberAccessibilityLabel(Text(country.name))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedFlag = country
            }
        }
    }
}

struct CountryFlagList_Previews: PreviewProvider {

    static var countryList: [Country] = {
        var codes = Locale.Region.isoRegions.compactMap { code in
            return Country(code: code.identifier)
        }
       return codes
            .sorted {
           $0.name < $1.name
       }
    }()

    static var previews: some View {
        NavigationView {
            CountryFlagList(countryFlags: Self.countryList, selectedFlag: .constant(Country(code: "FR")))
        }
    }
}

struct Country: Hashable, Identifiable, Equatable {
    var id: String {
        return code
    }

    let name: String
    let flag: String
    let code: String

    init(code: String) {
        self.code = code
        self.name = Locale.current.localizedString(forRegionCode: code) ?? ""

        let base: UInt32 = 127397
        var scalar = ""
        for value in code.unicodeScalars {
            scalar.unicodeScalars.append(UnicodeScalar(base + value.value)!)
        }
        self.flag = String(scalar)
    }
}
