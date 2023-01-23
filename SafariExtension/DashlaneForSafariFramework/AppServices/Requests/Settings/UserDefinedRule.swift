import Foundation

struct UserDefinedRule: Codable, Hashable {

    let ruleId: String
    let hashId: String
    let domain: String
    let domType: String
    let oldSignification: String
    let newSignification: String
    let status: String

    var isDisabled: Bool {
        return newSignification == "nothing"
    }

    init(ruleId: String = "",
         hashId: String = "",
         domain: String,
         domType: String = "",
         oldSignification: String = "",
         newSignification: String = "nothing",
         status: String = "") {
        self.ruleId = ruleId
        self.hashId = hashId
        self.domain = domain
        self.domType = domType
        self.oldSignification = oldSignification
        self.newSignification = newSignification
        self.status = status
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ruleId)
        hasher.combine(hashId)
    }
}
