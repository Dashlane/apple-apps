import DesignSystem
import SwiftUI
import CorePersonalData
import UIDelight

struct BreachView<Model: BreachViewModel>: View {

    let model: Model

    var body: some View {
        HStack(spacing: 16) {
            BreachIconView(model: model.iconViewModel)
            VStack(alignment: .leading, spacing: 4) {
                website
                info
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 10))
    }

    private var website: some View {
        Text(model.url.displayDomain.capitalizingFirstLetter())
            .font(.body)
            .foregroundColor(.ds.text.neutral.catchy)
    }

    private var info: some View {
        Text(model.label)
            .font(.footnote)
            .foregroundColor(model.hasBeenAddressed ? .ds.text.positive.standard : .ds.text.warning.standard)
    }
}

struct BreachView_Previews: PreviewProvider {

    static var breachWithPassword: DWMSimplifiedBreach {
        return DWMSimplifiedBreach(breachId: "test1", url: PersonalDataURL(rawValue: "test1.com"), leakedPassword: "test", date: nil)
    }

    static var breachWithoutPassword: DWMSimplifiedBreach {
        return DWMSimplifiedBreach(breachId: "test2", url: PersonalDataURL(rawValue: "test2.com"), leakedPassword: nil, date: nil)
    }

    static var securedItem: Credential {
        return Credential(url: PersonalDataURL(rawValue: "_"))
    }

    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            VStack(spacing: 20) {
                BreachView(model: BreachViewModel.mock(for: breachWithPassword))
                BreachView(model: BreachViewModel.mock(for: breachWithoutPassword))
                BreachView(model: BreachViewModel.mock(for: securedItem))
            }
        }.previewLayout(.sizeThatFits)
    }
}

private extension Credential {
    init(url: PersonalDataURL) {
        self.init()
        self.url = url
    }
}
