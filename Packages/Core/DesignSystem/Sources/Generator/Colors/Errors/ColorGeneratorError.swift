import Foundation

enum ColorGeneratorError: Error, LocalizedError {
  case darkAndLightPalettesNotIdentical(differences: Set<String>? = nil)

  var errorDescription: String? {
    switch self {
    case .darkAndLightPalettesNotIdentical(let differences):
      let header =
        "Color generation failed because light mode and dark mode color palettes on Specify contain different values. For color assets to be generated, it's required that the two palettes have identical set of colors."

      guard let differences = differences else {
        return header
      }

      let differencesDescription = "\nTo proceed, please resolve the differences with these colors:"
      let colors = differences.reduce(into: "", { $0 += ("\n" + $1) })
      return header + differencesDescription + colors
    }
  }
}
