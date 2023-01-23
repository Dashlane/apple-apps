import SwiftUI
import UIDelight

struct MiniBrowserPasswordGeneratorCardView: View {
    private var action: DetailFieldActionSheet.Action

    @Environment(\.sizeCategory) var sizeCategory
    @State private var shouldShowOptions: Bool = false
    @ObservedObject var model: MiniBrowserPasswordGeneratorCardViewModel

    private var optionsButtonTitle: String {
        return shouldShowOptions ? L10n.Localizable.dwmOnboardingCardPWGTabLessOptions : L10n.Localizable.dwmOnboardingCardPWGTabMoreOptions
    }

    let maxHeight: CGFloat

    init(model: MiniBrowserPasswordGeneratorCardViewModel, action: DetailFieldActionSheet.Action, maxHeight: CGFloat) {
        self.model = model
        self.action = action
        self.maxHeight = maxHeight
    }

    private var refreshImageHeightAndWidth: CGFloat {
        sizeCategory.isAccessibilityCategory ? 32 : 16
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(L10n.Localizable.dwmOnboardingCardPWGTabNewPasswordTitle)
                        .foregroundColor(Color.white)
                        .font(.headline)
                        .padding(.bottom, 4)

                    Spacer()

                    Button(action: {
                        self.model.refreshPassword()
                    }, label: {
                        Image(asset: FiberAsset.refreshButton)
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: refreshImageHeightAndWidth, height: refreshImageHeightAndWidth, alignment: .center)
                    })
                }

                ZStack {
                    BreachPasswordGeneratorField(text: model.generatedPassword)
                        .actions([action])
                        .fiberFieldType(.password)
                        .padding(.trailing, 16.0)
                        .frame(minHeight: 48.0)
                }
                .background(Color.white)
                .cornerRadius(12.0)

                Text(L10n.Localizable.dwmOnboardingCardPWGTabGeneratorSubtitle)
                    .font(.footnote)
                    .foregroundColor(Color.white)
                    .padding(.top, 8.5)
                    .fixedSize(horizontal: false, vertical: true)

                ArrowToggleButton(title: optionsButtonTitle,
                                  action: {
                                    withAnimation {
                                        self.shouldShowOptions.toggle()
                                    }
                })
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.vertical, 24)

                if shouldShowOptions {
                    passwordOptionsView
                }
            }
            .padding(24)
            .colorScheme(.light)
            .embedInScrollViewIfNeeded()
        }
        .frame(maxHeight: maxHeight)
        .background(Color(asset: FiberAsset.mainGreen))
        .onAppear {
            self.model.logDisplay()
        }
    }

    private var passwordOptionsView: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("\(L10n.Localizable.kwPadExtensionGeneratorLength.uppercased()) \(String(format: "%g", self.model.passwordLength))")
                    .foregroundColor(Color(asset: FiberAsset.secondaryActionText))
                    .font(.footnote)

                HStack {
                    Text("4").font(.body).foregroundColor(Color.white)
                    ColoredSlider(minTrackColor: FiberAsset.sliderAccentColor.color,
                                  maxTrackColor: FiberAsset.grey04.color,
                                  range: 4...32,
                                  step: 1.0,
                                  value: self.$model.passwordLength)
                    Text("32")
                        .font(.body)
                        .foregroundColor(Color.white)
                }

                Text(L10n.Localizable.kwPadExtensionOptions.uppercased())
                    .foregroundColor(Color(asset: FiberAsset.secondaryActionText))
                    .font(.body)

                MiniBrowserToggleView(title: L10n.Localizable.kwPadExtensionGeneratorLetters, isOn: self.$model.passwordGenLettersEnabled)
                    .disabled(!self.model.passwordGenDigitsEnabled)
                    .fixedSize(horizontal: false, vertical: true)
                MiniBrowserToggleView(title: L10n.Localizable.kwPadExtensionGeneratorDigits, isOn: self.$model.passwordGenDigitsEnabled)
                    .disabled(!self.model.passwordGenLettersEnabled)
                    .fixedSize(horizontal: false, vertical: true)
                MiniBrowserToggleView(title: L10n.Localizable.kwPadExtensionGeneratorSymbols, isOn: self.$model.passwordGenSymbolsEnabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color(asset: FiberAsset.midGreen))
            .cornerRadius(8)
        }
    }
}

struct MiniBrowserPasswordGeneratorCardView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            MiniBrowserPasswordGeneratorCardView(model: MiniBrowserPasswordGeneratorCardViewModel(usageLogService: DWMLogService.fakeService), action: .copy({_, _ in}), maxHeight: 305)
        }.previewLayout(.sizeThatFits)
    }
}
