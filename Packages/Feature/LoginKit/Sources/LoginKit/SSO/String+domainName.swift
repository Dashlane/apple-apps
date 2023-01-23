import Foundation

extension String {
    var domainName: String {
        return self.components(separatedBy: "_").last ?? ""
    }
}
