import Foundation

struct DataLeakInfo: Decodable {

    enum HashMethod: String, Decodable {
        case plaintext
    }

    struct Info: Decodable {
        let email: String
        let type: Breach.LeakedData
        let hashMethod: HashMethod
        let value: String
    }

    let breachId: String
    let data: [Info]
}

extension Array where Element == DataLeakInfo {
    func leaked(_ info: Breach.LeakedData) -> Bool {
        return self.contains(where: { (tmpInfo) -> Bool in
            tmpInfo.data.leaked(info)
        })
    }
}

extension Array where Element == DataLeakInfo.Info {
    func leaked(_ info: Breach.LeakedData) -> Bool {
        return self.contains(where: { (tmpInfo) -> Bool in
            tmpInfo.type == info
        })
    }
}
