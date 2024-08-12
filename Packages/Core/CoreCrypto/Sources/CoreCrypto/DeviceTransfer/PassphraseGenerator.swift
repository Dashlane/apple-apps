import Foundation

struct PassphraseGenerator {

  let seed: Data

  let wordList: [String]

  public init(seed: Data) throws {
    self.seed = seed
    guard
      let configsURL = Bundle.module.url(forResource: "eff_large_wordlist", withExtension: "json")
    else {
      fatalError("Should have config files in resources")
    }
    let content = try Data(contentsOf: configsURL)
    wordList = try JSONDecoder().decode([String].self, from: content)
  }

  func generate() throws -> String {

    guard seed.count == 32 else {
      throw GeneratorError.wrongSeedSize
    }

    var passphrase = [String]()
    let maxRandomInt = Int(floor(Double(UInt32.max) / Double(wordList.count))) * wordList.count

    for i in stride(from: 0, to: 32, by: 4) where passphrase.count < 5 {
      let subdata = seed.subdata(in: i..<i + 4)
      let curr = subdata.withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian

      if curr < maxRandomInt {
        let word = wordList[Int(curr) % wordList.count]
        passphrase.append(word)
      }
    }
    return passphrase.joined(separator: " ")
  }
}

extension PassphraseGenerator {
  enum GeneratorError: Error {
    case wrongSeedSize
  }
}
