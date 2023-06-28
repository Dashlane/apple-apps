import Foundation
import CorePasswords
import Combine

final class MiniBrowserPasswordGeneratorCardViewModel: ObservableObject {
    @Published var passwordLength: Double = 14.0
    @Published var passwordGenLettersEnabled: Bool = true
    @Published var passwordGenDigitsEnabled: Bool = true
    @Published var passwordGenSymbolsEnabled: Bool = false
    @Published var generatedPassword: String = ""

    private var bag = Set<AnyCancellable>()

    private func compositionOptions(letters: Bool, digits: Bool, symbols: Bool) -> PasswordCompositionOptions {
        var options: PasswordCompositionOptions = []

        if digits {
            options.update(with: .numerals)
        }
        if letters {
            options.update(with: .lowerCaseLetters)
            options.update(with: .upperCaseLetters)
        }
        if symbols {
            options.update(with: .symbols)
        }

        return options
    }

    init() {
        Publishers.CombineLatest4($passwordGenDigitsEnabled, $passwordGenLettersEnabled, $passwordGenSymbolsEnabled, $passwordLength)
            .map({ digits, letters, symbols, length in
                self.generatePassword(options: self.compositionOptions(letters: letters, digits: digits, symbols: symbols),
                                      length: Int(length))
            })
            .assign(to: \.generatedPassword, on: self)
            .store(in: &bag)
    }

    private func generatePassword(options: PasswordCompositionOptions? = nil, length: Int? = nil) -> String {
        let defaultCompositionOptions = compositionOptions(letters: passwordGenLettersEnabled, digits: passwordGenDigitsEnabled, symbols: passwordGenSymbolsEnabled)
        let defaultLength = 24

        return PasswordGenerator(length: Int(length ?? defaultLength),
                                 composition: options ?? defaultCompositionOptions,
                                 distinguishable: true).generate()
    }

    func refreshPassword() {
        generatedPassword =
            generatePassword(options: compositionOptions(letters: passwordGenLettersEnabled,
                                                         digits: passwordGenDigitsEnabled,
                                                         symbols: passwordGenSymbolsEnabled),
                             length: Int(passwordLength))
    }
}
